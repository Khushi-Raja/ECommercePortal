import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_button.dart';

import '../../constants/color.dart';
import 'add_address_screen.dart';

class ShippingAddressScreen extends StatefulWidget {
  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final userID = FirebaseAuth.instance.currentUser?.uid;
  List<Address> addresses = [];

  @override
  void initState() {
    super.initState();
    if (userID != null) {
      _fetchAddresses();
    }
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

  void _addNewAddress() {
    // Navigate to the new address screen or show a dialog to add the address
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAddressScreen()),
    ).then((_) {
      _fetchAddresses(); // Refresh the address list after adding a new address
    });
  }

  void _selectAddress(Address address) {
    // Navigate to payment method screen with selected address
    // You can pass the selected address details to the payment screen
    Navigator.pushNamed(context, '/payment', arguments: address);
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
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No address found. Please add a new address.'),
                  const SizedBox(height: 20),
                  CustomButton(
                    backgroundColor: Colors.purple,
                    textColor: Colors.white,
                    buttonName: 'Add New Address',
                    onPressed: _addNewAddress,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return ListTile(
                  title: Text(address.fullAddress),
                  subtitle: Text(address.mobileNumber),
                  onTap: () => _selectAddress(address),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewAddress,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Address {
  final String country;
  final String mobileNumber;
  final String flatHouseNo;
  final String areaStreet;
  final String pinCode;
  final String townCity;
  final String state;
  final String userID;

  Address({
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
      country: data['Country/Region'],
      mobileNumber: data['Mobile number'],
      flatHouseNo: data['Flat, House no., Building, Company, Apartment'],
      areaStreet: data['Area, Street, Village'],
      pinCode: data['Pin code'],
      townCity: data['Town City'],
      state: data['State'],
      userID: data['userID'],
    );
  }

  String get fullAddress {
    return '$flatHouseNo, $areaStreet, $townCity, $state, $pinCode';
  }
}
