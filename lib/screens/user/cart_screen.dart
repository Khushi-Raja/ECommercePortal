import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:link/constants/color.dart';
import '../../components/custom_circular_progress_indicator.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Future<Map<String, dynamic>?> fetchProductDetails(String productID) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('product')
          .where('productID', isEqualTo: productID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return {
          'name': data['productName'] ?? "Unknown Product",
          'image': data['displayImage'] ?? "https://via.placeholder.com/50",
          'price': data['price'] is String
              ? double.tryParse(data['price']) ?? 0
              : data['price'],
          'discount': data['discount'] is String
              ? double.tryParse(data['discount']) ?? 0
              : data['discount'] ?? 0,
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
    required double price,
    required int quantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                productImage,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$quantity x ₹${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "₹${(quantity * price).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _customIcon(icon: Icons.remove, onTap: onDecrement),
                const SizedBox(height: 8),
                Container(
                  width: 30,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                _customIcon(icon: Icons.add, onTap: onIncrement),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem({
    required BuildContext context,
    required String productName,
    required String productImage,
    required double price,
    required double discount,
    required int quantity,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required VoidCallback onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red,
              icon: Icons.delete_rounded,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: buildCartCard(
          productName: productName,
          productImage: productImage,
          price: price,
          quantity: quantity,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
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
        height: 23,
        width: 23,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, color: Colors.grey, size: 18),
      ),
    );
  }

  Widget _buildPricingRow(String label, double value, {bool isFinal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.w600 : FontWeight.normal,
              color: isFinal ? Colors.green : Colors.grey.shade700,
            ),
          ),
          Text(
            '₹${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.w600 : FontWeight.normal,
              color: value < 0 ? Colors.red : (isFinal ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userID = FirebaseAuth.instance.currentUser?.uid;

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
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('UserID', isEqualTo: userID)
            .where('isOrderDone', isEqualTo: false)
            .snapshots(),
        builder: (context, cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomCupertinoActivityIndicator());
          }

          if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your cart is empty!"));
          }

          final cartItems = cartSnapshot.data!.docs;
          final productFutures = cartItems
              .map((doc) => fetchProductDetails(doc['ProductID']))
              .toList();

          return FutureBuilder<List<Map<String, dynamic>?>>(
            future: Future.wait(productFutures),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CustomCupertinoActivityIndicator());
              }

              if (productSnapshot.hasError || !productSnapshot.hasData) {
                return const Center(child: Text("Error loading products"));
              }

              final productDetails = productSnapshot.data!;
              final List<Widget> cartCards = [];
              double originalTotal = 0.0;
              double discountTotal = 0.0;

              for (int i = 0; i < cartItems.length; i++) {
                final cartItem = cartItems[i];
                final details = productDetails[i];
                if (details == null) continue;

                final price = details['price'] as double;
                final discount = details['discount'] as double;
                final quantity = cartItem['Quantity'] as int;
                final itemPrice = price * quantity;
                final itemDiscount = (price * (discount / 100)) * quantity;

                originalTotal += itemPrice;
                discountTotal += itemDiscount;

                cartCards.add(
                  _buildCartItem(
                    context: context,
                    productName: details['name'],
                    productImage: details['image'],
                    price: price,
                    discount: discount,
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
                    onDelete: () async {
                      await cartItem.reference.delete();
                    },
                  ),
                );
              }

              final double finalAmount = originalTotal - discountTotal;

              return Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(bottom: 150),
                    children: cartCards,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildPricingRow('Original Price', originalTotal),
                          if (discountTotal > 0)
                            _buildPricingRow('Discount', -discountTotal),
                          _buildPricingRow(
                            'Final Amount',
                            finalAmount,
                            isFinal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}