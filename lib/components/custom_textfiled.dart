import 'package:flutter/cupertino.dart'; // Importing Cupertino package for iOS styles
import 'package:flutter/material.dart'; // Importing Material package for common widgets
import 'package:flutter/services.dart'; // Importing services package for input formatters

class CustomTextFormField extends StatelessWidget {
  final String? Function(String?)?
      validator; // Validator function for form validation
  final TextEditingController controller; // Controller to handle text input
  final TextInputType keyboardType; // Keyboard type for different input formats
  final String labelText; // Label text for the TextFormField
  final Widget? prefixIcon; // Optional prefix icon for the input field
  final bool obscureText; // Whether to obscure the text (useful for passwords)
  final int?
      inputFormatNumber; // Input formatter to limit text length or formatting
  final bool enabled; // To enable or disable the input field
  final int? maxLength; // Max length for the input (optional)
  final int? maxLines; // Max lines allowed in the input field (optional)
  final String? initialValue; // Initial value for the input field (optional)
  void Function(String)? onChanged;

  // Constructor to initialize the required parameters
  CustomTextFormField({
    super.key,
    required this.validator,
    required this.controller,
    required this.keyboardType,
    required this.labelText,
    this.prefixIcon,
    required this.obscureText,
    this.inputFormatNumber,
    this.enabled = true,
    this.maxLength,
    this.maxLines = 1, // Default is single line
    this.initialValue,
    this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: TextFormField(
        textInputAction: TextInputAction.next,
        onChanged: onChanged,
        enabled: enabled,
        // Whether the field is enabled or disabled
        initialValue: initialValue,
        // Initial value for the text input
        obscureText: obscureText,
        // Whether to hide the text (for password fields)
        validator: validator,
        // Validation logic for form input
        inputFormatters: [
          LengthLimitingTextInputFormatter(inputFormatNumber),
          // Limit input length
        ],
        controller: controller,
        // Text editing controller
        keyboardType: keyboardType,
        // Type of keyboard for input (e.g., text, number)
        maxLength: maxLength,
        // Max length for input (optional)
        maxLines: maxLines,
        // Max lines for input (default 1)
        cursorColor: CupertinoColors.black,
        // Custom cursor color
        cursorHeight: 20,
        // Custom cursor height
        cursorWidth: 2,
        // Custom cursor width
        decoration: InputDecoration(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10), // Rounded border for the input field
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              borderSide: BorderSide(color: Colors.black),
            ),
            labelText: labelText,
            // Label text displayed inside the input field
            labelStyle: const TextStyle(
              color: Colors.grey, // Label text color
              fontSize: 15, // Label text font size
              fontWeight: FontWeight.w600, // Label text boldness
            ),
            prefixIcon: prefixIcon,
            // Optional prefix icon
            prefixIconColor: Colors.grey,
        ),
      ),
    );
  }
}
