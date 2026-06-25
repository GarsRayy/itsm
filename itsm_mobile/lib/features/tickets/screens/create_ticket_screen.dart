import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../models/service_catalog.dart';
import '../repositories/catalog_repository.dart';
import '../../users/models/user_profile.dart';
import '../../users/controllers/user_controller.dart';
import '../controllers/ticket_controller.dart';

/// Screen for manually creating a new IT ticket.
/// Features dynamic dropdown menus that populate from the service catalog.
class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();

  // Dynamic selections
  UserProfile? _selectedUser;
  ServiceCatalog? _selectedCatalog;
  ServiceItem? _selectedItem;

  // Data
  List<ServiceCatalog> _catalogs = [];
  List<ServiceItem> _items = [];
  bool _isLoadingCatalogs = true;
  bool _isLoadingItems = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCatalogs();
  }

  Future<void> _loadCatalogs() async {
    try {
      final repo = ref.read(catalogRepositoryProvider);
      final catalogs = await repo.fetchCatalogs();
      setState(() {
        _catalogs = catalogs;
        _isLoadingCatalogs = false;
      });
    } catch (e) {
      setState(() => _isLoadingCatalogs = false);
      if (mounted) SnackbarUtils.showError(context, 'Failed to load catalogs: $e');
    }
  }

  Future<void> _loadItems(int catalogId) async {
    setState(() {
      _isLoadingItems = true;
      _selectedItem = null;
      _items = [];
    });

    try {
      final repo = ref.read(catalogRepositoryProvider);
      final items = await repo.fetchItemsByCatalog(catalogId);
      setState(() {
        _items = items;
        _isLoadingItems = false;
      });
    } catch (e) {
      setState(() => _isLoadingItems = false);
      if (mounted) SnackbarUtils.showError(context, 'Failed to load sub-categories: $e');
    }
  }

  Future<void> _submitTicket() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedItem == null) {
      SnackbarUtils.showError(context, 'Please select a service sub-category.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(catalogRepositoryProvider);
      final ticket = await repo.createManualTicket(
        reporterName: _selectedUser?.fullName ?? 'Walk-in',
        phoneNumber: _selectedUser?.phoneNumber ?? '-',
        userProfileId: _selectedUser?.id,
        serviceItemId: _selectedItem!.id,
        title: '[${_selectedItem!.code}] ${_selectedItem!.name}',
        description: _descriptionCtrl.text.trim(),
        requestType: _selectedItem!.requestType,
        priority: _selectedItem!.requestType == 'incident' ? 'high' : 'medium',
      );

      // Refresh ticket list
      ref.read(ticketControllerProvider.notifier).refresh();

      if (mounted) {
        SnackbarUtils.showSuccess(context, 'Ticket ${ticket.ticketCode} created!');
        context.pop();
      }
    } catch (e) {
      if (mounted) SnackbarUtils.showError(context, 'Failed to create ticket: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(userControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Create Ticket', style: AppTextStyles.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.spacing24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.spacing8),

                  // ── Section 1: Reporter ─────────────────────
                  _buildSectionHeader('👤 Reporter / Pelapor', delay: 100),
                  const SizedBox(height: AppSizes.spacing12),
                  _buildUserSelector(usersState)
                      .animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppSizes.spacing24),

                  // ── Section 2: Service ──────────────────────
                  _buildSectionHeader('🛠️ Service / Layanan', delay: 300),
                  const SizedBox(height: AppSizes.spacing12),
                  _buildCatalogDropdown()
                      .animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  const SizedBox(height: AppSizes.spacing16),

                  // ── Section 3: Sub-Category ─────────────────
                  if (_selectedCatalog != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('📋 Sub-Category', delay: 0),
                        const SizedBox(height: AppSizes.spacing12),
                        _buildItemDropdown(),
                        const SizedBox(height: AppSizes.spacing16),
                      ],
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

                  // ── Section 4: Request type badge ───────────
                  if (_selectedItem != null)
                    _buildRequestTypeBadge()
                        .animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),
                  if (_selectedItem != null)
                    const SizedBox(height: AppSizes.spacing24),

                  // ── Section 5: Description ──────────────────
                  _buildSectionHeader('📝 Detail Masalah', delay: 500),
                  const SizedBox(height: AppSizes.spacing12),
                  _buildDescriptionField()
                      .animate(delay: 600.ms).fadeIn().slideY(begin: 0.1, end: 0),

                  const SizedBox(height: AppSizes.spacing32),

                  // ── Submit button ───────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitTicket,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textOnPrimary))
                          : const Icon(Icons.send_rounded),
                      label: Text(_isSubmitting ? 'Creating...' : 'Create Ticket'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                        ),
                        textStyle: AppTextStyles.titleMedium,
                      ),
                    ),
                  ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: AppSizes.spacing32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {int delay = 0}) {
    return Text(title, style: AppTextStyles.titleMedium)
        .animate(delay: delay.ms).fadeIn();
  }

  Widget _buildUserSelector(UsersState usersState) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16, vertical: AppSizes.spacing4),
      child: DropdownButtonFormField<UserProfile>(
        initialValue: _selectedUser,
        dropdownColor: AppColors.surfaceDark,
        isExpanded: true,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Select reporter (optional)',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          icon: const Icon(Icons.person_search_rounded, color: AppColors.textHint),
        ),
        items: usersState.users.map((u) {
          return DropdownMenuItem<UserProfile>(
            value: u,
            child: Text('${u.fullName}  •  ${u.phoneNumber}', overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedUser = val),
      ),
    );
  }

  Widget _buildCatalogDropdown() {
    if (_isLoadingCatalogs) {
      return const GlassmorphicContainer(
        padding: EdgeInsets.all(AppSizes.spacing16),
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryYellow, strokeWidth: 2)),
      );
    }

    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16, vertical: AppSizes.spacing4),
      child: DropdownButtonFormField<ServiceCatalog>(
        initialValue: _selectedCatalog,
        dropdownColor: AppColors.surfaceDark,
        isExpanded: true,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Select service category...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          icon: const Icon(Icons.category_rounded, color: AppColors.textHint),
        ),
        validator: (val) => val == null ? 'Please select a service' : null,
        items: _catalogs.map((c) {
          return DropdownMenuItem<ServiceCatalog>(
            value: c,
            child: Text(c.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) {
          setState(() => _selectedCatalog = val);
          if (val != null) _loadItems(val.id);
        },
      ),
    );
  }

  Widget _buildItemDropdown() {
    if (_isLoadingItems) {
      return const GlassmorphicContainer(
        padding: EdgeInsets.all(AppSizes.spacing16),
        child: Center(child: CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2)),
      );
    }

    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16, vertical: AppSizes.spacing4),
      child: DropdownButtonFormField<ServiceItem>(
        initialValue: _selectedItem,
        dropdownColor: AppColors.surfaceDark,
        isExpanded: true,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Select sub-category...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          icon: const Icon(Icons.list_alt_rounded, color: AppColors.textHint),
        ),
        items: _items.map((item) {
          final typeIcon = item.requestType == 'incident' ? '🔴' : '🔵';
          return DropdownMenuItem<ServiceItem>(
            value: item,
            child: Text('$typeIcon ${item.name}', overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: (val) => setState(() => _selectedItem = val),
      ),
    );
  }

  Widget _buildRequestTypeBadge() {
    final isIncident = _selectedItem!.requestType == 'incident';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16, vertical: AppSizes.spacing8),
      decoration: BoxDecoration(
        color: (isIncident ? AppColors.accentRed : AppColors.accentBlue).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
          color: (isIncident ? AppColors.accentRed : AppColors.accentBlue).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIncident ? Icons.warning_amber_rounded : Icons.build_circle_outlined,
            color: isIncident ? AppColors.accentRed : AppColors.accentBlue,
            size: AppSizes.iconSmall,
          ),
          const SizedBox(width: AppSizes.spacing8),
          Text(
            isIncident
                ? 'INCIDENT — Priority: HIGH'
                : 'SERVICE REQUEST — Priority: MEDIUM',
            style: AppTextStyles.labelMedium.copyWith(
              color: isIncident ? AppColors.accentRed : AppColors.accentBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField() {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(AppSizes.spacing16),
      child: TextFormField(
        controller: _descriptionCtrl,
        maxLines: 5,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Describe the issue in detail...\n(Location, affected device, since when, etc.)',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) return 'Description is required';
          if (val.trim().length < 10) return 'Please provide more detail (min 10 chars)';
          return null;
        },
      ),
    );
  }
}
