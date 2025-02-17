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
      addresses = snapshot.docs.map((doc) => Address.fromFirestore(doc)).toList();
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

  void _removeAddress(String addressID) async {
    await FirebaseFirestore.instance.collection('address').doc(addressID).delete();
    _fetchAddresses();
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Add delivery address',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: CustomButton(
            backgroundColor: Colors.purple,
            textColor: Colors.white,
            buttonName: 'Add a new delivery address',
            onPressed: () => _navigateToAddAddress(null),
          ),
        ),
        const Divider(thickness: 1, height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Select a delivery address',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CupertinoColors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('All addresses (${addresses.length})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const Divider(thickness: 1),
            if (addresses.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No saved addresses found. Please add a delivery address.', style: TextStyle(fontSize: 16)),
              ),
              _buildAddressSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: CustomButton(backgroundColor: Colors.grey[300]!, textColor: Colors.black, buttonName: 'Back to cart', onPressed: () => Navigator.pop(context)),
              )
            ] else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                value: address.id,
                                groupValue: selectedAddressID,
                                onChanged: (value) => setState(() => selectedAddressID = value!),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(address.fullAddress, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text(address.mobileNumber, style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(child: const Text('Edit'), onPressed: () => _navigateToAddAddress(address)),
                              const SizedBox(width: 10),
                              TextButton(onPressed: () => _removeAddress(address.id), child: const Text('Remove', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _buildAddressSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: CustomButton(backgroundColor: Colors.grey[300]!, textColor: Colors.black, buttonName: 'Back to cart', onPressed: () => Navigator.pop(context)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class Address {
  final String id, country, mobileNumber, flatHouseNo, areaStreet, pinCode, townCity, state, userID;

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
      country: data['Country/Region'] ?? '',
      mobileNumber: data['Mobile number'] ?? '',
      flatHouseNo: data['Flat, House no., Building, Company, Apartment'] ?? '',
      areaStreet: data['Area, Street, Village'] ?? '',
      pinCode: data['Pin code'] ?? '',
      townCity: data['Town City'] ?? '',
      state: data['State'] ?? '',
      userID: data['userID'] ?? '',
    );
  }

  String get fullAddress => '$flatHouseNo, $areaStreet, $townCity, $state, $pinCode';
}
