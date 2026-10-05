import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReminderPopup {
  static void show(
    BuildContext context, {
    required String arabicText,
    String? englishText,
    required String urduTranslation,
    required VoidCallback onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(arabicText, textAlign: TextAlign.center, style: AppTheme.arabicHeading),
            const SizedBox(height: 15),
            if (englishText != null)
              Text(englishText, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, color: AppTheme.primaryColor)),
            if (englishText != null)
              const SizedBox(height: 10),
            Text(urduTranslation, textAlign: TextAlign.center, style: AppTheme.urduBody),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              onDismiss();
              Navigator.pop(ctx);
            },
            child: const Text("Dismiss"),
          ),
        ],
      ),
    );
  }
}
