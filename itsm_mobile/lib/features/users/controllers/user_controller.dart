import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../repositories/user_repository.dart';

class UsersState {
  final bool isLoading;
  final List<UserProfile> users;
  final String searchQuery;
  final String? error;

  const UsersState({
    this.isLoading = false,
    this.users = const [],
    this.searchQuery = '',
    this.error,
  });

  List<UserProfile> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    final lowerQuery = searchQuery.toLowerCase();
    return users.where((u) {
      return u.fullName.toLowerCase().contains(lowerQuery) ||
             u.phoneNumber.contains(lowerQuery);
    }).toList();
  }

  UsersState copyWith({
    bool? isLoading,
    List<UserProfile>? users,
    String? searchQuery,
    String? error,
    bool clearError = false,
  }) {
    return UsersState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final userControllerProvider =
    StateNotifierProvider<UserController, UsersState>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserController(repo);
});

class UserController extends StateNotifier<UsersState> {
  UserController(this._repo) : super(const UsersState()) {
    fetchUsers();
  }

  final UserRepository _repo;

  Future<void> fetchUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final users = await _repo.fetchUsers();
      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final newUser = await _repo.createUser(data);
      state = state.copyWith(
        isLoading: false,
        users: [newUser, ...state.users],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to create user: $e');
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedUser = await _repo.updateUser(id, data);
      final index = state.users.indexWhere((u) => u.id == id);
      if (index != -1) {
        final newUsers = [...state.users];
        newUsers[index] = updatedUser;
        state = state.copyWith(isLoading: false, users: newUsers);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update user: $e');
    }
  }

  Future<void> importCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null || result.files.single.path == null) {
        return; // User canceled
      }

      final bytes = result.files.single.bytes;
      if (bytes == null) {
        throw Exception('Could not read file contents.');
      }

      state = state.copyWith(isLoading: true, clearError: true);

      final csvString = utf8.decode(bytes);
      final fields = Csv().decode(csvString);

      if (fields.length <= 1) {
        throw Exception('CSV file is empty or only contains headers.');
      }

      final headers = fields.first.map((e) => e.toString().toLowerCase().trim()).toList();
      
      // Expected headers (flexible): name/full_name, phone/phone_number, division, email
      final nameIdx = headers.indexWhere((h) => h.contains('name'));
      final phoneIdx = headers.indexWhere((h) => h.contains('phone') || h.contains('wa') || h.contains('whatsapp'));
      final divIdx = headers.indexWhere((h) => h.contains('division') || h.contains('divisi'));
      final emailIdx = headers.indexWhere((h) => h.contains('email'));

      if (nameIdx == -1 || phoneIdx == -1) {
        throw Exception('CSV must contain a Name and a Phone Number column.');
      }

      final rowsToInsert = <Map<String, dynamic>>[];

      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.isEmpty || row.every((element) => element.toString().trim().isEmpty)) {
          continue; // Skip empty rows
        }

        String rawPhone = row.length > phoneIdx ? row[phoneIdx].toString() : '';
        // Basic phone number cleaning: remove spaces, -, +, and convert leading 0 to 62
        rawPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
        if (rawPhone.startsWith('0')) {
          rawPhone = '62${rawPhone.substring(1)}';
        }

        if (rawPhone.isEmpty) continue; // Skip if no valid phone

        rowsToInsert.add({
          'full_name': row.length > nameIdx ? row[nameIdx].toString() : 'Unknown',
          'phone_number': rawPhone,
          'division': divIdx != -1 && row.length > divIdx ? row[divIdx].toString() : null,
          'email': emailIdx != -1 && row.length > emailIdx ? row[emailIdx].toString() : null,
          'is_active': true,
        });
      }

      if (rowsToInsert.isEmpty) {
        throw Exception('No valid data found to import.');
      }

      await _repo.bulkInsertUsers(rowsToInsert);
      
      // Re-fetch all users to get the generated IDs and proper ordering
      await fetchUsers();
      
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'CSV Import Failed: $e');
    }
  }
}
