import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/constants/color.dart';
import 'package:link/screens/user/cart_screen.dart';
import '../../constants/generate_id.dart';

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> productData;
  const ProductDetail({super.key, required this.productData});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  int _cartQuantity = 0;
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _checkCartStatus();
  }

  void _checkCartStatus() async {
    String? userID = firebaseAuth.currentUser?.uid;
    if (userID == null) return;

    final productID = widget.productData['productID'];

    final snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('UserID', isEqualTo: userID)
        .where('ProductID', isEqualTo: productID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _isInCart = true;
        _cartQuantity = snapshot.docs.first['Quantity'];
      });
    } else {
      setState(() {
        _isInCart = false;
        _cartQuantity = 0;
      });
    }
  }

  void _addToCart() async {
    try {
      int? lastID = await getLastID(collectionName: "cart", primaryKey: "CartID");
      int newID = (lastID ?? 0) + 1;
      String newIDString = newID.toString().padLeft(3, '0'); // Convert to zero-padded string
      String? userID = firebaseAuth.currentUser?.uid; // Get only the UID
      if (userID == null) return; // Ensure user is logged in

      await FirebaseFirestore.instance.collection('cart').doc(newIDString).set({
        'CartID': newIDString,
        'ProductID': widget.productData['productID'],
        'UserID': userID, // Store only the UID as a string
        'Quantity': 1,
        'isOrderDone': false,
        'Created': FieldValue.serverTimestamp(),
        'Modified': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isInCart = true;
        _cartQuantity = 1;
      });
    } catch (e) {
      print('Error adding to Cart: $e');
    }
  }

  void _incrementQuantity() async {
    setState(() {
      _cartQuantity++;
    });

    final productID = widget.productData['productID'];
    final snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('UserID', isEqualTo: firebaseAuth.currentUser?.uid)
        .where('ProductID', isEqualTo: productID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'Quantity': _cartQuantity,
        'Modified': FieldValue.serverTimestamp(),
      });
    }
  }

  void _decrementQuantity() async {
    if (_cartQuantity <= 0) return;

    final productID = widget.productData['productID'];
    final userID = firebaseAuth.currentUser?.uid;
    if (userID == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('UserID', isEqualTo: userID)
        .where('ProductID', isEqualTo: productID)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      if (_cartQuantity > 1) {
        setState(() => _cartQuantity--);
        await snapshot.docs.first.reference.update({
          'Quantity': _cartQuantity,
          'Modified': FieldValue.serverTimestamp(),
        });
      } else {
        // Delete the cart item
        await snapshot.docs.first.reference.delete();

        // Check if there are any remaining cart items (excluding placeholders)
        final remainingCartItems = await FirebaseFirestore.instance
            .collection('cart')
            .where('UserID', isEqualTo: userID)
            .where('Message', isEqualTo: null) // Exclude placeholders
            .get();

        // If no items left, add a placeholder
        if (remainingCartItems.docs.isEmpty) {
          await FirebaseFirestore.instance
              .collection('cart')
              .doc('placeholder_$userID') // Unique ID per user
              .set({
            'UserID': userID,
            'Message': 'Cart is empty',
            'Created': FieldValue.serverTimestamp(),
          });
        }

        setState(() {
          _cartQuantity = 0;
          _isInCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.productData['productName'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Image.network(
                  widget.productData['displayImage'],
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: _buildIcon(Icons.favorite_outline_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: Material(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.1),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded( // Ensures the product name does not overflow
                          child: Text(
                            widget.productData['productName'],
                            overflow: TextOverflow.ellipsis, // Truncate long names
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 8), // Space between name and counter
                        if (_isInCart)
                          Row(
                            mainAxisSize: MainAxisSize.min, // Prevents stretching
                            children: [
                              _customIcon(
                                icon: Icons.remove,
                                onTap: _decrementQuantity,
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    "$_cartQuantity",
                                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                              ),
                              _customIcon(
                                icon: Icons.add,
                                onTap: _incrementQuantity,
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('No Ratings', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(text: '₹${widget.productData['price']}'),
                          if (widget.productData['discount'] != null)
                            TextSpan(
                              text: '  ${widget.productData['discount']}% OFF',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Description', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      widget.productData['description'],
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_isInCart)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: kAppBarColor,
                ),
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

          if (_isInCart)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return CartScreen();
                      },
                    ),
                  ).then((value) {
                    setState(() {
                      _checkCartStatus();
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: kAppBarColor,
                ),
                child: const Text(
                  "Go to Cart",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey),
    );
  }

  Widget _customIcon({
    required IconData icon,
    double size = 23,
    required void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, color: Colors.grey, size: size * 0.7),
      ),
    );
  }
}