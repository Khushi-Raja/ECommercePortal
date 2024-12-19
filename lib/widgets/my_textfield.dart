import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  String? Function(String?)? validator;
  int? maxLines;


  MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      this.validator,
      this.maxLines
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
        ),
        obscureText: obscureText,
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }
}
