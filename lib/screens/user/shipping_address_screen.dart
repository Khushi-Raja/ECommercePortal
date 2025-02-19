import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_button.dart';
import 'package:link/screens/user/razorpay_payment.dart';
import '../../components/custom_snackbar.dart';
import '../../constants/color.dart';
import 'add_address_screen.dart';

class ShippingAddressScreen extends StatefulWidget {
  final double totalAmount;
  const ShippingAddressScreen({super.key, required this.totalAmount});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final userID = FirebaseAuth.instance.currentUser?.uid;
  List<Address> addresses = [];
  String? selectedAddressID;

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
        builder: (context) =>
            AddAddressScreen(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Select a delivery address',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            // Prevent overlap with button
            child: Column(
              children: [
                if (addresses.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No saved addresses found. Please add a delivery address.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ] else
                  Expanded(
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
                            color: Colors.grey.shade100,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                              const Icon(Icons.location_on,
                                                  color: Colors.black,
                                                  size: 16),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  address.fullAddress,
                                                  style: const TextStyle(
                                                      color: Colors.black,
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
                                              const SizedBox(width: 5),
                                              Text(
                                                address.mobileNumber,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Radio<String>(
                                      value: address.id,
                                      groupValue: selectedAddressID,
                                      onChanged: (value) =>
                                          setState(
                                                  () =>
                                              selectedAddressID = value!),
                                      fillColor:
                                      WidgetStateProperty.all(Colors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                CustomButton(
                                    buttonName: 'Deliver to this Address',
                                    backgroundColor: Colors.white,
                                    textColor: Colors.black,
                                    onPressed: () {
                                      setState(() =>
                                      selectedAddressID = address.id);
                                      _proceedToPayment();
                                    },
                                ),
                                const SizedBox(height: 5),
                                CustomButton(
                                  buttonName: 'Edit Address',
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  onPressed: () =>
                                      _navigateToAddAddress(address),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: CustomButton(
              backgroundColor: kAppBarColor,
              textColor: Colors.white,
              buttonName: 'Add a new delivery address',
              onPressed: () => _navigateToAddAddress(null),
            ),
          ),
        ],
      ),
    );
  }
  void _proceedToPayment() async {
    if (selectedAddressID == null) {
      SnackBarUtil.show(
          context: context, message: "Please select an address");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cartQuery = await FirebaseFirestore.instance
        .collection('cart')
        .where('UserID', isEqualTo: user.uid)
        .get();

    if (cartQuery.docs.isEmpty) {
      SnackBarUtil.show(
          context: context, message: "Your cart is empty");
      return;
    }

    // Create order
    final orderRef = FirebaseFirestore.instance.collection('orders').doc();
    try {
      await orderRef.set({
        'orderID': orderRef.id,
        'userID': user.uid,
        'addressID': selectedAddressID,
        'products': cartQuery.docs.map((doc) => doc.data()).toList(),
        'totalAmount': widget.totalAmount,
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
            amount: widget.totalAmount.toDouble(),
            orderID: orderRef.id,
          ),
        ),
      );
    } catch (e) {
      SnackBarUtil.show(
          context: context, message: "Error: $e");
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
      '$flatHouseNo, $areaStreet, $townCity, $state, $pinCode';
}
