import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/screens/user/cart_screen.dart';
import '../../constants/color.dart';

class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetail({Key? key, required this.productData}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int _cartQuantity = 0;
  bool _isInCart = false;

  @override
  void initState() {
    super.initState();
    _checkCartStatus();
  }

  String? getUserID() {
    final User? user = firebaseAuth.currentUser;
    return user?.uid;
  }

  void _checkCartStatus() async {
    final userID = getUserID();
    if (userID == null) return;

    final productID = widget.productData['productID'];

    final snapshot = await firestore
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
    }
  }

  void _addToCart() async {
    final userID = getUserID();
    if (userID == null) return;

    final productID = widget.productData['productID'];

    if (!_isInCart) {
      await firestore.collection('cart').add({
        'CartID': DateTime.now().millisecondsSinceEpoch.toString(),
        'ProductID': productID,
        'UserID': userID,
        'Quantity': 1,
        'isOrderDone': false,
        'Created': FieldValue.serverTimestamp(),
        'Modified': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isInCart = true;
        _cartQuantity = 1;
      });
    }
  }

  void _incrementQuantity() async {
    setState(() {
      _cartQuantity++;
    });

    final userID = getUserID();
    if (userID == null) return;

    final productID = widget.productData['productID'];
    final snapshot = await firestore
        .collection('cart')
        .where('UserID', isEqualTo: userID)
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
    if (_cartQuantity > 1) {
      setState(() {
        _cartQuantity--;
      });

      final userID = getUserID();
      if (userID == null) return;

      final productID = widget.productData['productID'];
      final snapshot = await firestore
          .collection('cart')
          .where('UserID', isEqualTo: userID)
          .where('ProductID', isEqualTo: productID)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'Quantity': _cartQuantity,
          'Modified': FieldValue.serverTimestamp(),
        });
      }
    } else if (_cartQuantity == 1) {
      final userID = getUserID();
      if (userID == null) return;

      final productID = widget.productData['productID'];
      final snapshot = await firestore
          .collection('cart')
          .where('UserID', isEqualTo: userID)
          .where('ProductID', isEqualTo: productID)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
      }

      setState(() {
        _cartQuantity = 0;
        _isInCart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: CupertinoColors.white),
        backgroundColor: kAppBarColor,
        title: Text(
          widget.productData['productName'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return const CartScreen();
                  },
                ),
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.shopping_cart),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Image.network(
                    widget.productData['displayImage'],
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 10,
                    right: 15,
                    child: _buildIcon(Icons.favorite_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.61,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                widget.productData['productName'],
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.grey),
                              ),
                              const Spacer(),
                              if (_isInCart)
                                Row(
                                  children: [
                                    _customIcon(
                                      icon: Icons.remove,
                                      onTap: _decrementQuantity,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "$_cartQuantity",
                                          style: const TextStyle(
                                              fontSize: 16, color: Colors.grey),
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
                          const SizedBox(height: 4),
                          const Text(
                            'No Ratings',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '₹${widget.productData['price']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.productData['discount'] != null)
                                Text(
                                  '  ${widget.productData['discount']}% OFF',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Description',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.productData['description'],
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
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
                          );
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
