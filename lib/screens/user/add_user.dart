import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_button.dart';
import 'package:link/components/custom_snackbar.dart';
import 'package:link/components/custom_textfiled.dart';
import 'package:link/constants/color.dart';
import 'package:link/constants/generate_id.dart';

class AddUser extends StatefulWidget {
  final String userID;
  final String name;
  final String email;

  const AddUser({
    super.key,
    required this.userID,
    required this.name,
    required this.email,
  });

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  late bool isMounted;

  @override
  void initState() {
    super.initState();
    isMounted = true;
    nameController.text = widget.name;
    emailController.text = widget.email;
  }

  @override
  void dispose() {
    nameController.dispose();
    surNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: CupertinoColors.white),
          backgroundColor: kAppBarColor,
          title: Text(
            widget.userID.isNotEmpty ? "Update User" : "Add User",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextFormField(
                  controller: nameController,
                  obscureText: false,
                  validator: (value) =>
                      value!.trim().isEmpty ? "Name is required" : null,
                  keyboardType: TextInputType.name,
                  labelText: 'Name',
                ),
                CustomTextFormField(
                  controller: surNameController,
                  obscureText: false,
                  validator: (value) =>
                      value!.trim().isEmpty ? "Surname is required" : null,
                  keyboardType: TextInputType.name,
                  labelText: 'Surname',
                ),
                CustomTextFormField(
                  controller: phoneNumberController,
                  obscureText: false,
                  validator: (value) =>
                      value!.trim().isEmpty ? "Phone Number is required" : null,
                  inputFormatNumber: 10,
                  keyboardType: TextInputType.number,
                  labelText: 'Phone Number',
                ),
                CustomTextFormField(
                  controller: emailController,
                  enabled: widget.userID.isEmpty,
                  // Disable when updating user
                  obscureText: false,
                  validator: (value) =>
                      value!.trim().isEmpty ? "Email is required" : null,
                  keyboardType: TextInputType.emailAddress,
                  labelText: 'Email',
                ),
                CustomTextFormField(
                  controller: addressController,
                  obscureText: false,
                  validator: (value) => null,
                  // Optional field
                  keyboardType: TextInputType.streetAddress,
                  labelText: 'Address (Optional)',
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: CustomButton(
                    buttonName:
                        widget.userID.isNotEmpty ? "Update User" : "Add User",
                    backgroundColor: CupertinoColors.black,
                    textColor: CupertinoColors.white,
                    onPressed: submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    try {
      if (widget.userID.isNotEmpty) {
        await updateUser();
        SnackBarUtil.show(
            context: context, message: "User Details Updated Successfully");
      } else {
        await addUser();
        SnackBarUtil.show(
            context: context, message: "User registered successfully.");
      }

      // Navigate back after success
      Navigator.of(context).pop();
    } catch (e) {
      SnackBarUtil.show(context: context, message: "Error: $e");
    }
  }

  Future<void> addUser() async {
    try {
      // Cache user and Firestore reference
      final ref = FirebaseFirestore.instance.collection('users');
      final email = emailController.text;
      final password = generateRandomPassword(); // Generate password once
      int newUserID =
          (await getLastID(collectionName: "users", primaryKey: "userID"))! + 1;

      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store new user details in Firestore
      final user = FirebaseAuth.instance.currentUser!;
      await ref.doc(user.uid).set({
        "userID": newUserID.toString(),
        'email': email,
        'role': "user",
        'name': nameController.text.trim(),
        'isDisabled': false,
      });

      await sendTemporaryPassword(email, password); // Send password via email
    } catch (e) {
      throw 'Error adding user: $e';
    }
  }

  Future<void> updateUser() async {
    try {
      // Update Firestore document directly
      final ref =
          FirebaseFirestore.instance.collection('users').doc(widget.userID);
      await ref.update({
        'name': nameController.text.trim(),
        'surname': surNameController.text.trim(),
        'phoneNumber': phoneNumberController.text.trim(),
        'address': addressController.text.trim(),
      });
    } catch (e) {
      throw 'Error updating user details: $e';
    }
  }

  String generateRandomPassword() {
    const int minLength = 12; // Increase minimum length for better security
    const int maxLength = 16; // Increased max length
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const specialChars =
        '@#\$%^&*()-_=+{}[]|:;<>,.?/'; // Adding special characters
    final allChars = lowercase + uppercase + numbers + specialChars;

    final Random random = Random.secure();
    final length = minLength + random.nextInt(maxLength - minLength + 1);

    // Ensure password contains at least one lowercase, uppercase, number, and special character
    String generateRandomChar(String source) =>
        source[random.nextInt(source.length)];

    final password = [
      generateRandomChar(lowercase),
      generateRandomChar(uppercase),
      generateRandomChar(numbers),
      generateRandomChar(specialChars),
      ...List.generate(length - 4, (_) => generateRandomChar(allChars)),
    ];

    // Shuffle the password to avoid predictable character positions
    password.shuffle();

    return password.join();
  }

  Future<void> sendTemporaryPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw 'Error sending temporary password: $e';
    }
  }
}
