import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_button.dart';
import 'package:link/components/custom_snackbar.dart';
import 'package:link/components/custom_textfiled.dart';
import 'package:link/components/dateFormat.dart';
import 'package:link/constants/generate_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formSignUpKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (!formSignUpKey.currentState!.validate()) return;

    try {
      final authResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      int? lastID =
          await getLastID(collectionName: "users", primaryKey: "userID");
      int newID = lastID! + 1;

      // Save user details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authResult.user!.uid)
          .set({
        'userID': newID,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'user', // Default role
        'createdAt': getFormattedDateTime()
      });

      // Save login state in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('role', 'user');

      SnackBarUtil.show(
          context: context, message: "Account created successfully!");
      Navigator.pop(context); // Navigate back to Sign In
    } on FirebaseAuthException catch (e) {
      String errorMsg = "An error occurred";
      if (e.code == 'email-already-in-use') {
        errorMsg = "This email is already registered";
      } else if (e.code == 'weak-password') {
        errorMsg = "Password must be at least 6 characters";
      }
      SnackBarUtil.show(context: context, message: errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: formSignUpKey,
        child: Column(
          children: <Widget>[
            Text(
              "Sign Up",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Create a new account",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            Column(
              children: <Widget>[
                CustomTextFormField(
                  labelText: "Name",
                  controller: nameController,
                  obscureText: false,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Name is required"
                      : null,
                  keyboardType: TextInputType.text,
                ),
                CustomTextFormField(
                  labelText: "Email",
                  controller: emailController,
                  obscureText: false,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Email is required"
                      : null,
                  keyboardType: TextInputType.text,
                ),
                CustomTextFormField(
                  labelText: "Password",
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Password is required"
                      : value.length < 6
                          ? "Password must be at least 6 characters"
                          : null,
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
            CustomButton(
              onPressed: registerUser,
              backgroundColor: CupertinoColors.black,
              textColor: CupertinoColors.white,
              buttonName: "Sign Up",
            ),
          ],
        ),
      ),
    );
  }
}
