import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/admin_screen/product/product_list.dart';
import 'package:link/auth/signin_screen.dart';
import 'package:link/components/custom_circular_progress_indicator.dart';
import 'package:link/constants/color.dart';
import 'package:link/screens/admin/category/category_list.dart';
import 'package:link/screens/user/add_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({Key? key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String? displayName;
  String? userEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data on initialization
  }

  Future<void> fetchUserData() async {
    // Check if user data is already cached
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedName = prefs.getString('displayName');
    String? cachedEmail = prefs.getString('userEmail');

    setState(() {
      displayName = cachedName;
      userEmail = cachedEmail;
      isLoading = false;
    });
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
          'Admin Dashboard',
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
                Icons.ac_unit,
                color: kAppBarColor,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const CategoryList();
                    },
                  ),
                );
              },
              title: const Text(
                'Category',
                style: TextStyle(
                  color: CupertinoColors.black,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.ac_unit,
                color: kAppBarColor,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const ProductList();
                    },
                  ),
                );
              },
              title: const Text(
                'Product',
                style: TextStyle(
                  color: CupertinoColors.black,
                ),
              ),
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
        return snapshot.data()?['name'] ?? "User";
      }
    }
    return "User";
  }

  Future<void> navigateToProfile() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userSnapshot.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddUser(
            userID: uid,
            email: userSnapshot['email'],
            name: userSnapshot['name'],
          ),
        ),
      );
    }
  }
}
