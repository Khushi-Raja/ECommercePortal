import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:link/auth/signin_screen.dart';
import 'package:link/screens/admin/admin_dashboard.dart';
import 'package:link/screens/user/user_dashboard.dart';
import 'package:link/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      home: Splash(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF-Pro',
      ),
    ),
  );
}
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   late bool userIsLoggedIn;
//   late String userRole;
//
//   Future<void> getLoggedInState() async {
//     await Helper.getUserLoggedInSharedPreference().then((value) {
//       setState(() {
//         userIsLoggedIn = value ?? false;
//       });
//     });
//
//     await Helper.getUserRoleSharedPreference().then((role) {
//       setState(() {
//         userRole = role ?? 'user'; // Default role is 'user'.
//       });
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getLoggedInState();
//     Timer(
//       Duration(seconds: 3),
//           () => Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => userIsLoggedIn
//               ? (userRole == 'admin' ? AdminDashboard() : UserDashboard())
//               : SignInScreen(),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Shared Preferences",
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       ),
//     );
//   }
// }
