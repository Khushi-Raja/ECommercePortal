import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../constants/color.dart';
class ProductDetail extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductDetail({Key? key, required this.productData}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _cartQuantity = 0;

  void _incrementQuantity() {
    setState(() {
      _cartQuantity++;
    });
    // Add logic to update Firestore or global state
  }

  void _decrementQuantity() {
    if (_cartQuantity > 0) {
      setState(() {
        _cartQuantity--;
      });
      // Add logic to update Firestore or global state
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
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Image
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
          // Curved Detail Card
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      widget.productData['productName'],
                      style: const TextStyle(
                          fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'No Ratings',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        _customIcon(
                          icon: Icons.exposure_minus_1,
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
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        _customIcon(
                          icon: Icons.plus_one,
                          onTap: _incrementQuantity,
                        ),
                      ],
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