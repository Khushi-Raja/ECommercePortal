import 'package:flutter/cupertino.dart';

class ConfirmationPopup {
  // A method to display a confirmation popup using CupertinoAlertDialog
  static Future<bool> show({
    required BuildContext context, // BuildContext is required for showing the popup
    required VoidCallback yesFunction, // Function to execute when "Yes" is clicked
    required String title, // Title text for the popup
    required String content, // Content or message text for the popup
  }) async {
    return await showCupertinoModalPopup(
      context: context, // The context is passed for modal rendering
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          // The dynamic title for the confirmation dialog
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              fontFamily: 'SF-Pro',
            ),
          ),
          // The dynamic content for the confirmation dialog
          content: Text(
            content,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontFamily: 'SF-Pro',
            ),
          ),
          // Actions for the popup
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: yesFunction, // Executes the provided yesFunction
              child: const Text(
                "Yes",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.destructiveRed,
                  fontFamily: 'SF-Pro',
                ),
              ),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context, false); // Closes the dialog and returns false
              },
              child: const Text(
                "No",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.activeGreen,
                  fontFamily: 'SF-Pro',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}