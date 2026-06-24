import 'package:flutter/material.dart';

/// Common Dart/Flutter extension methods.
///
/// Keeps utility logic DRY by extending built-in types.

/// Context extensions for quick access to theme and media query data.
extension BuildContextExtensions on BuildContext {
  /// Shortcut for `Theme.of(this)`.
  ThemeData get theme => Theme.of(this);

  /// Shortcut for `Theme.of(this).colorScheme`.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Shortcut for `Theme.of(this).textTheme`.
  TextTheme get textTheme => theme.textTheme;

  /// Shortcut for `MediaQuery.sizeOf(this)`.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width.
  double get screenWidth => screenSize.width;

  /// Screen height.
  double get screenHeight => screenSize.height;

  /// Top padding (status bar height).
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// Bottom padding (navigation bar / home indicator).
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// Show a styled snackbar.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
      ),
    );
  }
}

/// String utility extensions.
extension StringExtensions on String {
  /// Capitalize the first letter.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate to [maxLength] with ellipsis.
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}…';
}
