import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_circular_progress_indicator.dart';
import 'package:link/components/custom_snackbar.dart';
import 'package:link/screens/user/add_address_screen.dart';
import 'package:link/screens/user/razorpay_payment.dart';
import '../../components/custom_button.dart';
import '../../constants/color.dart';

class CheckOutScreen extends StatefulWidget {
  final double originalTotal;
  final double discountTotal;
  final double finalAmount;

  const CheckOutScreen({
    super.key,
    required this.originalTotal,
    required this.discountTotal,
    required this.finalAmount,
  });

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final userID = FirebaseAuth.instance.currentUser?.uid;
  List<Address> addresses = [];
  String? selectedAddressID;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (userID != null) _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('address')
        .where('userID', isEqualTo: userID)
        .get();

    setState(() {
      addresses =
          snapshot.docs.map((doc) => Address.fromFirestore(doc)).toList();
    });
  }

  void _navigateToAddAddress(Address? address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(
          addressID: address?.id ?? '',
          countryName: address?.country ?? '',
          mobileNumber: address?.mobileNumber ?? '',
          flatHouseNumber: address?.flatHouseNo ?? '',
          areaStreet: address?.areaStreet ?? '',
          pinCode: address?.pinCode ?? '',
          city: address?.townCity ?? '',
          state: address?.state ?? '',
          userID: address?.userID ?? '',
        ),
      ),
    ).then((_) => _fetchAddresses());
  }

  void _showAddressSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('address')
                        .where('userID', isEqualTo: userID)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CustomCupertinoActivityIndicator());
                      }
                      return addresses.isEmpty
                          ? const Center(
                              child: Text(
                                "No saved addresses found. Please add a delivery address.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : SizedBox(
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 10),
                                itemCount: addresses.length,
                                itemBuilder: (context, index) {
                                  final address = addresses[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                            Icons.location_on,
                                                            color: Colors.black,
                                                            size: 16),
                                                        const SizedBox(
                                                            width: 5),
                                                        Expanded(
                                                          child: Text(
                                                            address.fullAddress,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.call,
                                                            color: Colors.black,
                                                            size: 16),
                                                        const SizedBox(
                                                            width: 5),
                                                        Text(
                                                          address.mobileNumber,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Radio<String>(
                                                    value: address.id,
                                                    groupValue:
                                                        selectedAddressID,
                                                    onChanged: (value) {
                                                      setSheetState(() =>
                                                          selectedAddressID =
                                                              value.toString());
                                                      setState(() =>
                                                          selectedAddressID =
                                                              value.toString());
                                                      Navigator.pop(context);
                                                    },
                                                    fillColor:
                                                        WidgetStateProperty.all(
                                                            Colors.black),
                                                  ),
                                                  IconButton(
                                                      onPressed: () =>
                                                          _navigateToAddAddress(
                                                              address),
                                                      icon: const Icon(
                                                          Icons.edit))
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CustomButton(
                    buttonName: 'Add a New Delivery Address',
                    backgroundColor: kAppBarColor,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                      _navigateToAddAddress(
                          null); // Navigate to add address screen
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: CupertinoColors.white),
        backgroundColor: kAppBarColor,
        title: const Text("Checkout",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            _buildContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Order Summary",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildPricingRow('Original Total', widget.originalTotal),
                  _buildPricingRow('Discount Total', -widget.discountTotal),
                  const Divider(height: 20, thickness: 1),
                  _buildPricingRow('Final Amount', widget.finalAmount,
                      isFinal: true),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildContainer(
              child: GestureDetector(
                onTap: _showAddressSelection,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Shipping Address",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    selectedAddressID != null
                        ? Text(
                            addresses
                                .firstWhere((address) =>
                                    address.id == selectedAddressID)
                                .fullAddress,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          )
                        : const Text(
                            "Tap to select an address",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // CustomButton(
            //   onPressed: () {
            //     _proceedToPayment();
            //   },
            //   backgroundColor: kAppBarColor,
            //   textColor: Colors.white,
            //   buttonName: 'Pay Now ₹${widget.finalAmount.toStringAsFixed(2)}',
            // ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: CustomButton(
          onPressed: () {
            _proceedToPayment();
          },
          backgroundColor: kAppBarColor,
          textColor: Colors.white,
          buttonName: 'Pay Now ₹${widget.finalAmount.toStringAsFixed(2)}',
        ),
      ),
    );
  }

  Widget _buildContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.1),
              blurRadius: 10,
              offset: Offset(0, -4))
        ],
      ),
      child: child,
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
                color: isFinal ? Colors.green : Colors.grey.shade700),
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

  void _proceedToPayment() async {
    if (selectedAddressID == null) {
      SnackBarUtil.show(context: context, message: "Please select an address");
      return;
    }
    if (userID == null) return;
    final cartQuery = await FirebaseFirestore.instance
        .collection('cart')
        .where('UserID', isEqualTo: userID)
        .get();
    if (cartQuery.docs.isEmpty) {
      SnackBarUtil.show(context: context, message: "Your cart is empty");
      return;
    }

    // Create order
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    try {
      await orderRef.set({
        'orderID': orderRef.id,
        'userID': userID,
        'addressID': selectedAddressID,
        'products': cartQuery.docs.map((doc) => doc.data()).toList(),
        'totalAmount': widget.finalAmount,
        'orderStatus': 'Pending',
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'modifiedAt': FieldValue.serverTimestamp(),
      });

      // Clear cart
      final batch = FirebaseFirestore.instance.batch();
      cartQuery.docs.forEach((doc) => batch.delete(doc.reference));
      await batch.commit();

      // Navigate to payment
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RazorpayPayment(
            amount: widget.finalAmount.toDouble(),
            orderID: orderRef.id,
          ),
        ),
      );
    } catch (e) {
      SnackBarUtil.show(context: context, message: "Error: $e");
    }
  }
}

class Address {
  final String id,
      country,
      mobileNumber,
      flatHouseNo,
      areaStreet,
      pinCode,
      townCity,
      state,
      userID;

  Address({
    required this.id,
    required this.country,
    required this.mobileNumber,
    required this.flatHouseNo,
    required this.areaStreet,
    required this.pinCode,
    required this.townCity,
    required this.state,
    required this.userID,
  });

  factory Address.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Address(
      id: doc.id,
      country: data['Country'] ?? '',
      mobileNumber: data['PhoneNo'] ?? '',
      flatHouseNo: data['HouseNo'] ?? '',
      areaStreet: data['Area'] ?? '',
      pinCode: data['PinCode'] ?? '',
      townCity: data['City'] ?? '',
      state: data['State'] ?? '',
      userID: data['userID'] ?? '',
    );
  }

  String get fullAddress =>
      '$flatHouseNo\n$areaStreet\n$townCity, $state ($pinCode)\n$country';
}
