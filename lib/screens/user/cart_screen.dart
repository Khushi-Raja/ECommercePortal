import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/constants/color.dart';

import '../../components/custom_circular_progress_indicator.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? getUserID() {
    final User? user = _auth.currentUser;
    return user?.uid;
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productID) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('product')
          .where('productID', isEqualTo: productID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;

        // Parse price as double
        final price = data['price'];
        final parsedPrice = price is String ? double.tryParse(price) ?? 0 : price;

        return {
          'name': data['productName'] ?? "Unknown Product",
          'image': data['displayImage'] ?? "https://via.placeholder.com/50",
          'price': parsedPrice, // Ensure price is a double
        };
      }
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    }
    return null;
  }

  Widget buildCartCard({
    required String productName,
    required String productImage,
    required double price, // Accept price as double
    required int quantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  productImage,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10), // Spacing
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "₹${price.toStringAsFixed(2)}", // Display price
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity Controls
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _customIcon(
                    icon: Icons.remove,
                    onTap: onDecrement,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        "$quantity",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _customIcon(
                    icon: Icons.add,
                    onTap: onIncrement,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _customIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, color: Colors.grey, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userID = getUserID();

    if (userID == null) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: CupertinoColors.white),
          backgroundColor: kAppBarColor,
          title: const Text(
            "Your Cart",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
        ),
        body: const Center(child: Text("Please log in to view your cart.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: CupertinoColors.white),
        backgroundColor: kAppBarColor,
        title: const Text(
          "Your Cart",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('cart')
            .where('UserID', isEqualTo: userID)
            .where('isOrderDone', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomCupertinoActivityIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your cart is empty!"));
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final productID = cartItem['ProductID'];
              final quantity = cartItem['Quantity'];

              return FutureBuilder<Map<String, dynamic>?>(
                future: fetchProductDetails(productID),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CustomCupertinoActivityIndicator());
                  }

                  final productData = productSnapshot.data;
                  if (productData == null) {
                    return const Center(child: Text("Product details not found."));
                  }

                  final productName = productData['name'];
                  final productImage = productData['image'];
                  final price = productData['price'] as double; // Extract price

                  return buildCartCard(
                    productName: productName,
                    productImage: productImage,
                    price: productData['price'], // Pass price here
                    quantity: quantity,
                    onIncrement: () async {
                      await cartItem.reference.update({
                        'Quantity': quantity + 1,
                        'Modified': FieldValue.serverTimestamp(),
                      });
                    },
                    onDecrement: () async {
                      if (quantity > 1) {
                        await cartItem.reference.update({
                          'Quantity': quantity - 1,
                          'Modified': FieldValue.serverTimestamp(),
                        });
                      } else {
                        await cartItem.reference.delete();
                      }
                    },
                  );
                },
              );

            },
          );
        },
      ),
    );
  }
}