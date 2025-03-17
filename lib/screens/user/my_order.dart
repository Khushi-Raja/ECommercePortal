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
  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: CupertinoColors.white,
          ),
          backgroundColor: kAppBarColor,
          title: const Text(
            'My Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
        ),
        body: const Center(child: Text("Please log in to view your orders.")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userID', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomCupertinoActivityIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;

              Timestamp? createdTimestamp = order['created'];
              String createdDate = createdTimestamp != null
                  ? getFormattedDateTime(dateToFormat: createdTimestamp.toDate())
                  : "No Date";

              // Convert stored String into List
              List<String> productIDs = order['productIDs'].toString().split(',');
              List<String> quantities = order['quantities'].toString().split(',');

              return Column(
                children: List.generate(productIDs.length, (i) {
                  return FutureBuilder<Map<String, dynamic>?>(
                    future: fetchProductDetails(productIDs[i].trim()),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!productSnapshot.hasData || productSnapshot.data == null) {
                        return const Center(child: Text("Product details not found."));
                      }

                      var productData = productSnapshot.data!;
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          leading: Image.network(
                            productData['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.network("https://via.placeholder.com/50"),
                          ),
                          title: Text(productData['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Price: \$${productData['price']}"),
                              Text("Quantity: ${quantities[i].trim()}"),
                              Text("Created: $createdDate"),
                              Text("Status: ${order['orderStatus']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productID) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('product')
          .where('productID', isEqualTo: productID)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      final data = snapshot.docs.first.data();

      return {
        'name': data['productName'] ?? "Unknown Product",
        'image': data['displayImage'] ?? "https://via.placeholder.com/50",
        'price': data['price'] is String
            ? double.tryParse(data['price']) ?? 0
            : data['price'],
      };
    } catch (e) {
      debugPrint("Error fetching product: $e");
      return null;
    }
  }
}
