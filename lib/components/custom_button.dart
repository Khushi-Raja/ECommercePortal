import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonName; // Button text label
  final Color backgroundColor; // Background color of the button
  final Color textColor; // Text color of the button
  final VoidCallback onPressed; // Function to execute when the button is pressed

  // Constructor to receive required properties
  const CustomButton({
    Key? key,
    required this.buttonName,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0), // Padding around the button
      child: Container(
        height: 45, // Fixed height for the button
        width: double.infinity, // Full width to stretch across available space
        decoration: BoxDecoration(
          color: backgroundColor, // Set the background color of the button
          borderRadius: BorderRadius.circular(10), // No border radius for a rectangular button
        ),
        child: TextButton(
          style: ButtonStyle(
            // Setting the overlay color when the button is pressed
            overlayColor: WidgetStateProperty.resolveWith(
                  (states) => Colors.black12, // Light black color on press
            ),
          ),
          onPressed: onPressed, // The action performed when the button is pressed
          child: Text(
            buttonName, // The text label on the button
            style: TextStyle(
              color: textColor, // Set the text color
              fontWeight: FontWeight.bold, // Bold text
              fontSize: 16, // Font size for the button text
            ),
          ),
        ),
      ),
    );
  }
}