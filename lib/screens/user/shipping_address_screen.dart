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
  final List<List<Color>> gradients = [
    [Colors.orangeAccent, Colors.deepOrange],
    [Colors.pinkAccent, Colors.redAccent],
    [Colors.purpleAccent, Colors.deepPurple],
    [Colors.greenAccent, Colors.teal],
  ];

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

  Widget _buildAddressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomButton(
        backgroundColor: Colors.transparent,
        textColor: Colors.white,
        buttonName: 'Add a new delivery address',
        onPressed: () => _navigateToAddAddress(null),
      ),
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
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Text('All addresses (${addresses.length})',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                if (addresses.isEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                        'No saved addresses found. Please add a delivery address.',
                        style: TextStyle(fontSize: 16)),
                  ),
                  _buildAddressSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: CustomButton(
                        backgroundColor: Colors.transparent,
                        textColor: Colors.black,
                        buttonName: 'Back to cart',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  )
                ] else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      final address = addresses[index];
                      final gradient = gradients[index % gradients.length];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
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
                                                color: Colors.white70,
                                                size: 16),
                                            const SizedBox(width: 5),
                                            Expanded(
                                              child: Text(
                                                address.fullAddress,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.call,
                                                color: Colors.white70,
                                                size: 16),
                                            const SizedBox(width: 5),
                                            Text(
                                              address.mobileNumber,
                                              style: const TextStyle(
                                                  color: Colors.white,
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
                                    onChanged: (value) => setState(
                                        () => selectedAddressID = value!),
                                    fillColor:
                                        MaterialStateProperty.all(Colors.white),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              CustomButton(
                                buttonName: 'Deliver to this Address',
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                onPressed: () {},
                              ),
                              const SizedBox(width: 8),
                              CustomButton(
                                buttonName: 'Edit Address',
                                backgroundColor: Colors.transparent,
                                textColor: Colors.white,
                                onPressed: () => _navigateToAddAddress(address),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  _buildAddressSection(),
                ]
              ],
            ),
          ),
        ],
      ),
    );
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
