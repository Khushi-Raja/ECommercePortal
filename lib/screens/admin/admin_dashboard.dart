import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/screens/admin/orders_list.dart';
import 'package:link/screens/admin/product/product_list.dart';
import 'package:link/auth/signin_screen.dart';
import 'package:link/constants/color.dart';
import 'package:link/screens/admin/category/category_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

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
    _initializeUserData(); // Load user data on initialization
    fetchUserStats(); // Fetch user statistics on dashboard load
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

  int totalUsers = 0;
  int totalAdmins = 0;
  int totalCustomers = 0;
  int verifiedUsers = 0;
  int unverifiedUsers = 0;

  Future<void> fetchUserStats() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      int adminCount = 0;
      int customerCount = 0;
      int verifiedCount = 0;
      int unverifiedCount = 0;

      for (var doc in usersSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Count role-based users
        String role = data['role'] ?? 'customer';
        if (role == 'admin') {
          adminCount++;
        } else {
          customerCount++;
        }

        // Email verification check
        bool isVerified = data['emailVerified'] ?? false;
        if (isVerified) {
          verifiedCount++;
        } else {
          unverifiedCount++;
        }
      }

      setState(() {
        totalUsers = usersSnapshot.docs.length;
        totalAdmins = adminCount;
        totalCustomers = customerCount;
        verifiedUsers = verifiedCount;
        unverifiedUsers = unverifiedCount;
      });
    } catch (e) {
      debugPrint("Error fetching user stats: $e");
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
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            DashboardTile(
              title: "Total Users",
              value: "$totalUsers",
            ),
            DashboardTile(
              title: "Total Admins",
              value: "$totalAdmins",
            ),
            DashboardTile(
              title: "Total Customers",
              value: "$totalCustomers",
            ),
            DashboardTile(
              title: "Verified Users",
              value: "$verifiedUsers",
            ),
            DashboardTile(
              title: "Unverified Users",
              value: "$unverifiedUsers",
            ),
          ],
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
            ListTile(
              leading: const Icon(
                Icons.category,
                color: kAppBarColor,
              ),
              onTap: () {
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
                Icons.production_quantity_limits,
                color: kAppBarColor,
              ),
              onTap: () {
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
                Icons.list_alt,
                color: kAppBarColor,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const OrdersList();
                    },
                  ),
                );
              },
              title: const Text(
                'Orders',
                style: TextStyle(
                  color: CupertinoColors.black,
                ),
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

class DashboardTile extends StatelessWidget {
  final String title;
  final String value;

  const DashboardTile({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink),
        ),
      ),
    );
  }
}
