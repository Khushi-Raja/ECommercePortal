import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:link/admin_screen/admin_home_screen.dart';
import 'package:link/admin_screen/category/category_list_screen.dart';
import 'package:link/login/login_page.dart';
import 'package:link/user_screen/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CategoryListScreen(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(), // listens to auth changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for auth state
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // If user is logged in, fetch their role
          return FutureBuilder<DocumentSnapshot>(
            future:
                _firestore.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (roleSnapshot.hasData) {
                // Extract the role from Firestore data
                final userRole = roleSnapshot.data!.get('role');
                if (userRole == 'admin') {
                  return AdminHomeScreen(); // Navigate to Admin Home
                } else {
                  return HomeScreen(); // Navigate to regular Home
                }
              } else if (roleSnapshot.hasError) {
                return Center(
                    child: Text('Error fetching role: ${roleSnapshot.error}'));
              } else {
                return AuthScreen(); // Fallback to AuthScreen if role not found
              }
            },
          );
        } else {
          // If no user is logged in, navigate to AuthScreen
          return AuthScreen();
        }
      },
    );
  }
}
