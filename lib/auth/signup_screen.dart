import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/auth/signin_screen.dart';
import 'package:link/components/custom_button.dart';
import 'package:link/components/custom_snackbar.dart';
import 'package:link/components/custom_textfiled.dart';
import 'package:link/components/dateFormat.dart';
import 'package:link/constants/generate_id.dart';

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/images/ecommerce1.webp", height: 150,width: 150,),
            const Text(
              "Get On Board,",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Create account to start your journey with us!",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
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
                  prefixIcon: const Icon(Icons.person),
                ),
                CustomTextFormField(
                  labelText: "Email",
                  controller: emailController,
                  obscureText: false,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Email is required"
                      : null,
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.email),
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
                  prefixIcon: const Icon(Icons.key),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: registerUser,
              backgroundColor: CupertinoColors.black,
              textColor: CupertinoColors.white,
              buttonName: "Sign Up",
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );
              },
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith<Color?>((states) => Colors.transparent),
                splashFactory: NoSplash.splashFactory,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
