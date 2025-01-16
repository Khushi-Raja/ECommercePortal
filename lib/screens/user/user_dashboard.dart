import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link/auth/signin_screen.dart';
import 'package:link/components/custom_circular_progress_indicator.dart';
import 'package:link/constants/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {
  UserDashboard({Key? key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String? displayName;
  String? userEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUserData(); // Load user data on initialization
  }

  Future<void> _initializeUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Attempt to load cached data first
    displayName = prefs.getString('displayName');
    userEmail = prefs.getString('userEmail');

    // If no cached data, fetch from Firestore
    if (displayName == null || userEmail == null) {
      await _fetchAndSaveUserData();
    }

    setState(() {
      isLoading = false; // Data is ready to display
    });
  }

  Future<void> _fetchAndSaveUserData() async {
    User? user = firebaseAuth.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (snapshot.exists) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Fetch and update values
        displayName = snapshot.data()?['name'];
        userEmail = user.email;

        // Cache the values for future use
        await prefs.setString('displayName', displayName!);
        await prefs.setString('userEmail', userEmail!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: const Text(
          'User Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CustomCupertinoActivityIndicator())
          : Center(
        child: Text(
          'Logged in as $userEmail',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Container(
              color: kAppBarColor,
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: CupertinoColors.white,
                      child: Text(
                        displayName != null ? displayName![0].toUpperCase() : "?",
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    displayName ?? "Loading...",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    userEmail ?? "No email",
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: kAppBarColor,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Clear cached data on logout
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SignInScreen();
                    },
                  ),
                );
              },
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: CupertinoColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:link/auth/signin_screen.dart';
// import 'package:link/components/custom_circular_progress_indicator.dart';
// import 'package:link/constants/color.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class UserDashboard extends StatefulWidget {
//   UserDashboard({Key? key});
//
//   @override
//   State<UserDashboard> createState() => _UserDashboardState();
// }
//
// class _UserDashboardState extends State<UserDashboard> {
//   FirebaseAuth firebaseAuth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: const IconThemeData(
//           color: CupertinoColors.white,
//         ),
//         backgroundColor: kAppBarColor,
//         title: const Text(
//           'User Dashboard',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: CupertinoColors.white,
//           ),
//         ),
//       ),
//       body: Center(
//         child: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CustomCupertinoActivityIndicator(),
//               );
//             }
//             if (snapshot.hasData && snapshot.data != null) {
//               return Text(
//                 'Logged in as ${snapshot.data!.email}',
//               );
//             }
//             return const Text(
//               'Not logged in',
//             );
//           },
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: const EdgeInsets.all(0),
//           children: [
//             FutureBuilder(
//               future: getUserDisplayName(),
//               builder: (context, AsyncSnapshot<String> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const DrawerHeader(
//                     child: Center(
//                       child: CustomCupertinoActivityIndicator(),
//                     ),
//                   );
//                 }
//                 if (snapshot.hasError) {
//                   return const DrawerHeader(
//                     child: Text(
//                       "Error fetching user data",
//                     ),
//                   );
//                 }
//                 return Container(
//                   color: kAppBarColor,
//                   width: double.infinity,
//                   height: 200,
//                   padding: const EdgeInsets.only(top: 20.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Align(
//                         alignment: Alignment.center,
//                         child: CircleAvatar(
//                           radius: 35,
//                           backgroundColor: CupertinoColors.white,
//                           child: Text(
//                             snapshot.data != null
//                                 ? snapshot.data![0].toUpperCase()
//                                 : "?",
//                             style: const TextStyle(
//                               fontSize: 30,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Text(
//                         snapshot.data ?? "Loading...",
//                         style: const TextStyle(color: Colors.white, fontSize: 20),
//                       ),
//                       Text(
//                         firebaseAuth.currentUser?.email ?? "No email",
//                         style: TextStyle(
//                           color: Colors.grey[200],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(
//                 Icons.login_rounded,
//                 color: kAppBarColor,
//               ),
//               onTap: () async {
//                 await FirebaseAuth.instance.signOut();
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 await prefs.clear();
//                 Navigator.of(context).pushReplacement(
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return const SignInScreen();
//                     },
//                   ),
//                 );
//               },
//               title: const Text(
//                 'Logout',
//                 style: TextStyle(
//                   color: CupertinoColors.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<String> getUserDisplayName() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
//           .instance
//           .collection('users')
//           .doc(user.uid)
//           .get();
//       if (snapshot.exists) {
//         if (snapshot.data()!.containsKey('name')) {
//           return snapshot.get('name');
//         } else {
//           return "User";
//         }
//       }
//     }
//     return "User";
//   }
// }