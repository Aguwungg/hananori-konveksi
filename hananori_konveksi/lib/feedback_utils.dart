import 'package:flutter/material.dart';

/// Centralized Feedback System for UI Notifications and Dialogs.
class AppFeedback {
  static const Duration _successDuration = Duration(milliseconds: 3500);
  static const Duration _errorDuration = Duration(milliseconds: 4500);
  static const Duration _warningDuration = Duration(milliseconds: 4000);
  static const Duration _infoDuration = Duration(milliseconds: 3500);

  static void _showCustomSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Duration duration,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(icon, color: textColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Satoshi',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Satoshi',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        elevation: 6,
        duration: duration,
      ),
    );
  }

  /// Menampilkan notifikasi sukses (hijau lembut)
  static void showSuccess(BuildContext context, {required String title, required String message}) {
    _showCustomSnackBar(
      context,
      title: title,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: const Color(0xFFE8F5E9), // Soft Green
      textColor: const Color(0xFF1B5E20), // Dark Green Text
      duration: _successDuration,
    );
  }

  /// Menampilkan notifikasi error (merah elegan)
  static void showError(BuildContext context, {required String title, required String message}) {
    _showCustomSnackBar(
      context,
      title: title,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: const Color(0xFFFFEBEE), // Soft Red
      textColor: const Color(0xFFB71C1C), // Dark Red Text
      duration: _errorDuration,
    );
  }

  /// Menampilkan notifikasi peringatan (amber/orange)
  static void showWarning(BuildContext context, {required String title, required String message}) {
    _showCustomSnackBar(
      context,
      title: title,
      message: message,
      icon: Icons.warning_rounded,
      backgroundColor: const Color(0xFFFFF8E1), // Soft Amber
      textColor: const Color(0xFFF57F17), // Dark Amber Text
      duration: _warningDuration,
    );
  }

  /// Menampilkan notifikasi info (biru)
  static void showInfo(BuildContext context, {required String title, required String message}) {
    _showCustomSnackBar(
      context,
      title: title,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: const Color(0xFFE3F2FD), // Soft Blue
      textColor: const Color(0xFF0D47A1), // Dark Blue Text
      duration: _infoDuration,
    );
  }

  /// Menampilkan dialog konfirmasi modern
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Lanjutkan',
    String cancelText = 'Batal',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Satoshi',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(cancelText),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDestructive
                            ? Colors.red.shade600
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.amber
                                : Colors.black),
                        foregroundColor: isDestructive
                            ? Colors.white
                            : (Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tombol reusable dengan state loading yang elegan
class AppLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isDestructive;

  const AppLoadingButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color bg = backgroundColor ?? (isDestructive
        ? Colors.red.shade600
        : (isDark ? Colors.amber : Colors.black));
        
    Color fg = textColor ?? (isDestructive
        ? Colors.white
        : (isDark ? Colors.black : Colors.white));

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Satoshi',
                ),
              ),
      ),
    );
  }
}
