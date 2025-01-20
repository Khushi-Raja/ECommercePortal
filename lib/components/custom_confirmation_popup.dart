import 'package:flutter/cupertino.dart';

/// A utility class to show a confirmation popup using CupertinoAlertDialog.
class ConfirmationPopup {
  static Future<bool> show({
    required BuildContext context,
    required VoidCallback yesFunction,
    required String title,
    required String content,
  }) async {
    return await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: Text(
            content,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          actions: <CupertinoDialogAction>[
            // "Yes" button
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: yesFunction,
              child: const Text(
                "Yes, Delete",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.destructiveRed,
                ),
              ),
            ),
            // "No" button
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "No",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeGreen,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
