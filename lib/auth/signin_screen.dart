import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link/auth/signup_screen.dart';
import 'package:link/components/custom_button.dart';
import 'package:link/components/custom_snackbar.dart';
import 'package:link/components/custom_textfiled.dart';
import 'package:link/screens/admin/admin_dashboard.dart';
import 'package:link/screens/user/user_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final formSignInKey = GlobalKey<FormState>();
  final formForgetPasswordDialogKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final forgetEmailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isMounted = false;
  bool _isSigningIn = false; // To prevent multiple sign-in attempts

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    emailController.dispose();
    forgetEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signUserIn() async {
    if (_isSigningIn ||
        !formSignInKey.currentState!.validate() ||
        !_isMounted) {
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    FocusScope.of(context).unfocus();

    try {
      SnackBarUtil.show(context: context, message: "Signing in...");

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final user = FirebaseAuth.instance.currentUser;
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (docSnapshot.exists) {
        Map<String, dynamic> userData =
            docSnapshot.data() as Map<String, dynamic>;

        final role = docSnapshot.get('role');

        // Save login state in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('role', role);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) {
            return role == "admin" ? AdminDashboard() : UserDashboard();
          }),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = "User does not exist";
          break;
        case 'wrong-password':
          errorMsg = "Incorrect password";
          break;
        default:
          errorMsg = "An error occurred, please try again";
      }
      SnackBarUtil.show(context: context, message: errorMsg);
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  AlertDialog buildResetPasswordDialog() {
    return AlertDialog(
      backgroundColor: CupertinoColors.white,
      title: const Text(
        'Forgot Password',
        style: TextStyle(
          fontFamily: "SF-Pro",
          color: CupertinoColors.black,
        ),
      ),
      content: Form(
        key: formForgetPasswordDialogKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CustomTextFormField(
              controller: forgetEmailController,
              obscureText: false,
              validator: (value) => value == null || value.trim().isEmpty
                  ? "Email is required"
                  : null,
              keyboardType: TextInputType.text,
              labelText: "Enter your email",
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            if (formForgetPasswordDialogKey.currentState!.validate()) {
              resetPassword(forgetEmailController.text);
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            "Submit",
            style: TextStyle(
              fontFamily: "SF-Pro",
              color: CupertinoColors.black,
            ),
          ),
        )
      ],
    );
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
        key: formSignInKey,
        child: Column(
          children: <Widget>[
            Text(
              "Login",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Login to your account",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
            Column(
              children: <Widget>[
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
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? "Password is required"
                      : null,
                  keyboardType: TextInputType.text,
                  labelText: 'Password',
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) =>
                          buildResetPasswordDialog(),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            CustomButton(
              onPressed: signUserIn,
              backgroundColor: CupertinoColors.black,
              textColor: CupertinoColors.white,
              buttonName: "Sign In",
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );
              },
              child: const Text(
                "Don't have an account? Sign Up",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
