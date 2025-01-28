import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final userID = getUserID();

    if (userID == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Your Cart"),
        ),
        body: const Center(
          child: Text("Please log in to view your cart."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('cart')
            .where('UserID', isEqualTo: userID)
            .where('isOrderDone', isEqualTo: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Your cart is empty!"),
            );
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final productID = cartItem['ProductID'];
              final quantity = cartItem['Quantity'];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag),
                  title: Text("Product ID: $productID"),
                  subtitle: Text("Quantity: $quantity"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () async {
                          if (quantity > 1) {
                            await cartItem.reference.update({
                              'Quantity': quantity - 1,
                              'Modified': FieldValue.serverTimestamp(),
                            });
                          } else {
                            await cartItem.reference.delete();
                          }
                        },
                      ),
                      Text("$quantity"),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          await cartItem.reference.update({
                            'Quantity': quantity + 1,
                            'Modified': FieldValue.serverTimestamp(),
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Add logic to handle checkout functionality
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Checkout"),
                content: const Text("Proceed to checkout functionality coming soon!"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
          child: const Text("Proceed to Checkout"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
        ),
      ),
    );
  }
}