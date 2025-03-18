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
    fetchOrderStats(); // Fetch order summary
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

  double totalRevenue = 0.0;
  int totalOrders = 0;
  int totalItemsOrdered = 0;
  double highestOrderValue = 0.0;
  double lowestOrderValue = 0.0;
  int pendingOrders = 0;
  int completedOrders = 0;

  Future<void> fetchOrderStats() async {
    try {
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      double revenue = 0;
      int orderCount = 0; // Start counting only valid orders
      int itemCount = 0;
      double maxOrder = 0.0;
      double minOrder = double.infinity;
      int pending = 0;
      int completed = 0;

      for (var doc in ordersSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Skip invalid documents (e.g., placeholder)
        if (!data.containsKey('price') || !data.containsKey('quantities') || data.containsKey('placeholder')) {
          continue;
        }

        orderCount++; // Only count valid orders

        // Handle price safely
        double orderPrice = (data['price'] ?? 0).toDouble();
        revenue += orderPrice;

        // Handle quantities safely (if stored as a comma-separated string)
        int orderItemCount = 0;
        if (data['quantities'] is String) {
          orderItemCount = (data['quantities'] as String)
              .split(",")
              .map((e) => int.tryParse(e.trim()) ?? 0)
              .reduce((a, b) => a + b);
        } else if (data['quantities'] is int) {
          orderItemCount = data['quantities']; // If stored as a single number
        }
        itemCount += orderItemCount;

        // Track max and min order values
        if (orderPrice > maxOrder) maxOrder = orderPrice;
        if (orderPrice < minOrder) minOrder = orderPrice;

        // Handle order status safely (ensure lowercase comparison)
        String status = (data['orderStatus'] ?? 'pending').toString().toLowerCase();
        if (status == 'pending') {
          pending++;
        } else if (status == 'delivered' || status == 'completed') {
          completed++;
        }
      }

      // Update UI
      setState(() {
        totalRevenue = revenue;
        totalOrders = orderCount;
        totalItemsOrdered = itemCount;
        highestOrderValue = maxOrder;
        lowestOrderValue = minOrder == double.infinity ? 0.0 : minOrder;
        pendingOrders = pending;
        completedOrders = completed;
      });
    } catch (e) {
      throw("Error fetching order stats: $e"); // Debugging
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "User Stats",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
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
              // DashboardTile(
              //   title: "Verified Users",
              //   value: "$verifiedUsers",
              // ),
              // DashboardTile(
              //   title: "Unverified Users",
              //   value: "$unverifiedUsers",
              // ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  "Order Stats",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              DashboardTile(
                title: "Total Orders",
                value: "$totalOrders",
              ),
              DashboardTile(
                title: "Total Revenue",
                value: "₹${totalRevenue.toStringAsFixed(2)}",
              ),
              DashboardTile(
                title: "Total Items Ordered",
                value: "$totalItemsOrdered",
              ),
              DashboardTile(
                title: "Highest Order Value",
                value: "₹${highestOrderValue.toStringAsFixed(2)}",
              ),
              DashboardTile(
                title: "Lowest Order Value",
                value: "₹${lowestOrderValue.toStringAsFixed(2)}",
              ),
              DashboardTile(
                title: "Pending Orders",
                value: "$pendingOrders",
              ),
              DashboardTile(
                title: "Completed Orders",
                value: "$completedOrders",
              ),
            ],
          ),
        
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
      margin: const EdgeInsets.only(bottom: 10),
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
