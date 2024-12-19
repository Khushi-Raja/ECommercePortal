import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Signup with name, email, password, and role
  Future<User?> signUp(String name, String email, String password, String role) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // Store user data in Firestore with default role 'user'
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': 'user', // Default role is 'user'
          'createdAt': FieldValue.serverTimestamp(),
        });
        return user;
      }
      return null;
    } catch (e) {
      print('Signup Error: $e');
      return null;
    }
  }

  // Login
  Future<AuthResult?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user =  userCredential.user;

      if (user != null) {
        // Fetch user role from Firestore (either 'admin' or 'user')
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc['role'];
          return AuthResult(user: user, role: role); // Return user and role as AuthResult
        }
      }
      return null;

    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}

class AuthResult {
  final User user;
  final String role;

  AuthResult({required this.user, required this.role});
}

