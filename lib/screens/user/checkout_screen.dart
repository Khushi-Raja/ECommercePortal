import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_button.dart';
import 'package:link/constants/color.dart';
import '../../components/custom_circular_progress_indicator.dart';
import '../../components/custom_textfiled.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  @override
  Widget build(BuildContext context) {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: CupertinoColors.white),
        backgroundColor: kAppBarColor,
        title: const Text(
          "Checkout Screen",
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
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomCupertinoActivityIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your cart is empty!"));
          }

          final cartItems = snapshot.data!.docs;
          return _buildCartList(cartItems);
        },
      ),
    );
  }

  Widget _buildCartList(List<QueryDocumentSnapshot> cartItems) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.only(bottom: 200),
          itemCount: cartItems.length,
          itemBuilder: (context, index) => CartItemWidget(
            cartDocId: cartItems[index].id,
            key: ValueKey(cartItems[index].id),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              _buildTotalSummary(cartItems),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSummary(List<QueryDocumentSnapshot> cartItems) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getAllProductDetails(cartItems),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        double originalTotal = 0;
        double discountTotal = 0;
        for (int i = 0; i < cartItems.length; i++) {
          final productData = snapshot.data![i];
          final quantity = cartItems[i]['Quantity'] as int;
          final price = productData['price'] as double;
          final discount = productData['discount'] as double;

          originalTotal += price * quantity;
          discountTotal += (price * (discount / 100)) * quantity;
        }

        return _buildTotalContainer(
          originalTotal: originalTotal,
          discountTotal: discountTotal,
          finalAmount: originalTotal - discountTotal,
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getAllProductDetails(
      List<QueryDocumentSnapshot> cartItems) async {
    List<Map<String, dynamic>> productDetails = [];
    for (final cartItem in cartItems) {
      final productID = cartItem['ProductID'];
      final product = await fetchProductDetails(productID);
      if (product != null) productDetails.add(product);
    }
    return productDetails;
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
        'discount': data['discount'] is String
            ? double.tryParse(data['discount']) ?? 0
            : data['discount'] ?? 0,
      };
    } catch (e) {
      debugPrint("Error fetching product: $e");
      return null;
    }
  }

  Widget _buildTotalContainer({
    required double originalTotal,
    required double discountTotal,
    required double finalAmount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(128, 128, 128, 0.1),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPricingRow('Original Price', originalTotal),
          _buildPricingRow('Discount', -discountTotal),
          const Divider(height: 20, thickness: 1),
          _buildPricingRow('Total Price', finalAmount, isFinal: true),
          CustomButton(
            buttonName: "Confirm Order",
            backgroundColor: kAppBarColor,
            textColor: Colors.white,
            onPressed: () {
              showCustomBottomSheet(context);
            },
          )
        ],
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
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.w600 : FontWeight.normal,
              color: value < 0
                  ? Colors.red
                  : (isFinal ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemWidget extends StatefulWidget {
  final String cartDocId;

  const CartItemWidget({super.key, required this.cartDocId});

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget>
    with AutomaticKeepAliveClientMixin {
  late final Stream<DocumentSnapshot> _cartStream;
  late final Future<Map<String, dynamic>?> _productFuture;

  @override
  void initState() {
    super.initState();
    _cartStream = FirebaseFirestore.instance
        .collection('cart')
        .doc(widget.cartDocId)
        .snapshots();
    _productFuture = _fetchProductDetails();
  }

  Future<Map<String, dynamic>?> _fetchProductDetails() async {
    final cartDoc = await _cartStream.first;
    final productID = cartDoc['ProductID'];
    return _CheckoutScreenState().fetchProductDetails(productID);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder<DocumentSnapshot>(
      stream: _cartStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final quantity = snapshot.data!['Quantity'] as int;
        return FutureBuilder<Map<String, dynamic>?>(
          future: _productFuture,
          builder: (context, productSnapshot) {
            if (!productSnapshot.hasData) return const SizedBox.shrink();

            final productData = productSnapshot.data!;
            return _buildCartCard(productData, quantity);
          },
        );
      },
    );
  }

  Widget _buildCartCard(Map<String, dynamic> productData, int quantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.1),
              blurRadius: 6,
              offset: Offset(0, 2),
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
                  productData['image'],
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
                      productData['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$quantity x ₹${productData['price'].toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "₹${(quantity * productData['price']).toStringAsFixed(2)}",
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
          ],
        ),
      ),
    );
  }
}

void showCustomBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      TextEditingController nameController = TextEditingController();
      TextEditingController phoneNoController = TextEditingController();
      TextEditingController streetController = TextEditingController();
      TextEditingController pinCodeController = TextEditingController();
      TextEditingController cityController = TextEditingController();
      TextEditingController stateController = TextEditingController();
      TextEditingController countryController = TextEditingController();
      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          color: Colors.white,
        ),
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                CustomTextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Name is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  labelText: 'Country/Region',
                  obscureText: false,
                  prefixIcon: const Icon(Icons.person),
                ),
                CustomTextFormField(
                  controller: phoneNoController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Mobile Number is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  labelText: 'Mobile Number',
                  obscureText: false,
                  prefixIcon: const Icon(Icons.phone),
                ),
                CustomTextFormField(
                  controller: streetController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Street is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  labelText: 'Street',
                  obscureText: false,
                  prefixIcon: const Icon(Icons.favorite),
                ),
                CustomTextFormField(
                  controller: pinCodeController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Pin Code is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  labelText: 'Pin Code',
                  obscureText: false,
                  prefixIcon: const Icon(Icons.post_add),
                ),
                CustomTextFormField(
                  controller: cityController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Town or City is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  labelText: 'Town/City',
                  obscureText: false,
                  prefixIcon: const Icon(Icons.location_city),
                ),
                CustomTextFormField(
                  controller: stateController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "State is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  labelText: 'State',
                  obscureText: false,
                  prefixIcon: const Icon(Icons.satellite),
                ),
                CustomTextFormField(
                  controller: countryController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Country is required";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                  labelText: 'Country',
                  obscureText: false,
                  prefixIcon: const Icon(Icons.flag_circle),
                ),
                const SizedBox(height: 5),
                CustomButton(
                  backgroundColor: kAppBarColor,
                  textColor: Colors.white,
                  buttonName: 'Save Address',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
