import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:link/admin_screen/admin_home_screen.dart';
import 'package:link/user_screen/home_screen.dart';
import 'package:link/widgets/my_button.dart';
import 'package:link/widgets/my_textfield.dart';
import 'auth_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // For Name
  final TextEditingController _confirmPasswordController = TextEditingController(); // For Confirm Password
  bool isLogin = true;
  String selectedRole = 'user'; // Default role is 'user'

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void handleAuth() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (isLogin) {
      AuthResult? result = await _authService.login(email, password);
      if (result != null) {
        String role = result.role; // Extract the role

        // Navigate to the correct screen based on the role
        if (role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdminHomeScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      } else {
        print('Login failed.');
        // Optionally, show an error message to the user
      }
    } else {
      if (password != confirmPassword) {
        print('Passwords do not match.');
        return; // Optionally show an error message
      }

      User? user = await _authService.signUp(name, email, password, selectedRole);
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        print('Signup failed.');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Register', style: const TextStyle(color: Colors.white),),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Name field for Sign Up only
            if (!isLogin)
              MyTextField(
                controller: _nameController,
                hintText: "Full Name",
                obscureText: false,
              ),
            const SizedBox(height: 10),
            MyTextField(
              controller: _emailController,
              hintText: "Email",
              obscureText: false,
            ),
            const SizedBox(height: 10),
            MyTextField(
              controller: _passwordController,
              hintText: "Password",
              obscureText: true,
              maxLines: 1,
            ),
            const SizedBox(height: 10),

            // Confirm Password field for Sign Up only
            if (!isLogin)
              MyTextField(
                controller: _confirmPasswordController,
                hintText: "Confirm Password",
                obscureText: true,
                maxLines: 1,
              ),
            const SizedBox(height: 20),
            MyButton(onTap: handleAuth, text: isLogin ? 'Login' : 'Register'),
            const SizedBox(height: 10),
            TextButton(
              onPressed: toggleForm,
              style: ButtonStyle(
                splashFactory: NoSplash.splashFactory, // Disable the splash effect
                overlayColor: MaterialStateProperty.all(Colors.transparent), // Disable the highlight color
              ),
              child: Text(
                isLogin
                    ? 'Don\'t have an account? Create an account'
                    : 'Already have an account? Login',
              ),
            ),
          ],
        ),
      ),
    );
  }
}