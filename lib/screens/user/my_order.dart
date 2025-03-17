import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_circular_progress_indicator.dart';
import '../../components/dateFormat.dart';
import '../../constants/color.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  List<Map<String, dynamic>> ordersWithProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrdersWithProducts();
  }

  Future<void> fetchOrdersWithProducts() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userID', isEqualTo: currentUser.uid)
          .get();

      if (ordersSnapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      List<Map<String, dynamic>> orders = [];
      Set<String> productIDsSet = {}; // Unique product IDs for batch fetching

      for (var orderDoc in ordersSnapshot.docs) {
        var order = orderDoc.data();
        Timestamp? createdTimestamp = order['created'];
        String createdDate = createdTimestamp != null
            ? getFormattedDateTime(dateToFormat: createdTimestamp.toDate())
            : "No Date";

        List<String> productIDs = order['productIDs'].toString().split(',');
        List<String> quantities = order['quantities'].toString().split(',');

        // Collect all product IDs for batch fetching
        productIDsSet.addAll(productIDs.map((id) => id.trim()));

        orders.add({
          ...order,
          'createdDate': createdDate,
          'productIDs': productIDs.map((id) => id.trim()).toList(),
          'quantities': quantities.map((q) => q.trim()).toList(),
        });
      }

      // Fetch product details in a single query
      Map<String, Map<String, dynamic>> productDetailsMap = await fetchProductDetailsBatch(productIDsSet);

      // Map product details to each order
      for (var order in orders) {
        List<Map<String, dynamic>> products = [];
        for (int i = 0; i < order['productIDs'].length; i++) {
          String productID = order['productIDs'][i];
          if (productDetailsMap.containsKey(productID)) {
            products.add({
              ...productDetailsMap[productID]!,
              'quantity': order['quantities'][i],
            });
          }
        }
        order['products'] = products;
      }

      setState(() {
        ordersWithProducts = orders;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, Map<String, dynamic>>> fetchProductDetailsBatch(Set<String> productIDs) async {
    Map<String, Map<String, dynamic>> productsMap = {};

    if (productIDs.isEmpty) return productsMap;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('product')
          .where('productID', whereIn: productIDs.toList())
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data();
        productsMap[data['productID']] = {
          'name': data['productName'] ?? "Unknown Product",
          'image': data['displayImage'] ?? "https://via.placeholder.com/50",
          'price': data['price'] is String ? double.tryParse(data['price']) ?? 0 : data['price'],
        };
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }

    return productsMap;
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text("Please log in to view your orders.")),
      );
    }

    if (isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: CustomCupertinoActivityIndicator()),
      );
    }

    if (ordersWithProducts.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(child: Text("No orders found.")),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView.builder(
        itemCount: ordersWithProducts.length,
        itemBuilder: (context, index) {
          var order = ordersWithProducts[index];
          var products = order['products'] as List<Map<String, dynamic>>;

          return Column(
            children: products.map((product) {
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                    product['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.network("https://via.placeholder.com/50"),
                  ),
                  title: Text(product['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price: \$${product['price']}"),
                      Text("Quantity: ${product['quantity']}"),
                      Text("Created: ${order['createdDate']}"),
                      Text("Status: ${order['orderStatus']}"),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: CupertinoColors.white),
      backgroundColor: kAppBarColor,
      title: const Text(
        'My Orders',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CupertinoColors.white),
      ),
    );
  }
}
