import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../localization/app_strings.dart';

class ReminderPopup {
  /// Shows the popup and returns a function to close it programmatically.
  static VoidCallback show(
    BuildContext context, {
    required String arabicText,
    String? englishText,
    required String urduTranslation,
    required VoidCallback onDismiss,
    String lang = 'ur',
  }) {
    bool isOpen = true;

    void closePopup() {
      if (isOpen && Navigator.of(context, rootNavigator: true).canPop()) {
        isOpen = false;
        onDismiss();
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(arabicText,
                textAlign: TextAlign.center, style: AppTheme.arabicHeading),
            const SizedBox(height: 15),
            if (englishText != null)
              Text(englishText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16, color: AppTheme.secondaryColor)),
            if (englishText != null) const SizedBox(height: 10),
            Text(urduTranslation,
                textAlign: TextAlign.center, style: AppTheme.urduBody),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              isOpen = false;
              onDismiss();
              Navigator.pop(ctx);
            },
            child: Text(S.get('dismiss', lang)),
          ),
        ],
      ),
    ).then((_) => isOpen = false);

    return closePopup;
  }
}
