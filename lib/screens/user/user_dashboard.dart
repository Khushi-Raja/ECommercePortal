import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link/auth/signin_screen.dart';
import 'package:link/components/custom_circular_progress_indicator.dart';
import 'package:link/constants/color.dart';

class UserDashboard extends StatefulWidget {
  UserDashboard({Key? key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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
      body: Center(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CustomCupertinoActivityIndicator(),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return Text(
                'Logged in as ${snapshot.data!.email}',
              );
            }
            return const Text(
              'Not logged in',
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            FutureBuilder(
              future: getUserDisplayName(),
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const DrawerHeader(
                    child: Center(
                      child: CustomCupertinoActivityIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const DrawerHeader(
                    child: Text(
                      "Error fetching user data",
                    ),
                  );
                }
                return Container(
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
                            snapshot.data != null
                                ? snapshot.data![0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        snapshot.data ?? "Loading...",
                        style: const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        firebaseAuth.currentUser?.email ?? "No email",
                        style: TextStyle(
                          color: Colors.grey[200],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.login_rounded,
                color: kAppBarColor,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
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

  Future<String> getUserDisplayName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        if (snapshot.data()!.containsKey('name')) {
          return snapshot.get('name');
        } else {
          return "User";
        }
      }
    }
    return "User";
  }
}
