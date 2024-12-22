import 'package:flutter/cupertino.dart'; // Importing Cupertino package for iOS styles
import 'package:flutter/material.dart'; // Importing Material package for common widgets

class SnackBarUtil {
  // Static method to show a SnackBar with a custom message
  static void show({
    required BuildContext
        context, // The context in which to display the SnackBar
    required String message, // The message to display in the SnackBar
    Color backgroundColor =
        CupertinoColors.black, // Default background color is black
    int durationSeconds = 2, // Default duration for the SnackBar display
  }) {
    // Using ScaffoldMessenger to display the SnackBar in the provided context
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Setting the content of the SnackBar as the provided message
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold, // Bold text for the message
          ),
        ),
        duration: Duration(seconds: durationSeconds),
        // Customizable display duration
        backgroundColor: backgroundColor, // Customizable background color
      ),
    );
  }
}
