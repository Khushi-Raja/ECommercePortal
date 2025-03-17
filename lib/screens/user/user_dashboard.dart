import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link/auth/signin_screen.dart';
import 'package:link/constants/color.dart';
import 'package:link/screens/user/cart_screen.dart';
import 'package:link/screens/user/my_order.dart';
import 'package:link/screens/user/user_product_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/custom_circular_progress_indicator.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

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
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

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
                        displayName != null
                            ? displayName![0].toUpperCase()
                            : "?",
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
            customListTile(
              icon: Icons.category_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const UserProductList();
                    },
                  ),
                );
              },
              text: 'Product',
            ),
            customListTile(
              icon: Icons.shopping_cart_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const CartScreen();
                    },
                  ),
                );
              },
              text: 'Cart',
            ),
            customListTile(
              icon: Icons.local_shipping_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const MyOrder();
                    },
                  ),
                );
              },
              text: 'My Orders',
            ),
            customListTile(
              icon: Icons.logout,
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
              text: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  Widget customListTile(
      {required String text, void Function()? onTap, IconData? icon}) {
    return ListTile(
      leading: Icon(
        icon,
        color: kAppBarColor,
      ),
      onTap: onTap,
      title: Text(
        text,
        style: const TextStyle(
          color: CupertinoColors.black,
        ),
      ),
    );
  }
}
