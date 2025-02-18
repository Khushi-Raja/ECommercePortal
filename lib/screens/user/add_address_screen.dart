import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_button.dart';
import '../../components/custom_textfiled.dart';
import '../../components/dateFormat.dart';
import '../../constants/color.dart';
import '../../constants/generate_id.dart';

class AddAddressScreen extends StatefulWidget {
  final String addressID;
  final String countryName;
  final String mobileNumber;
  final String flatHouseNumber;
  final String areaStreet;
  final String pinCode;
  final String city;
  final String state;
  final String userID;

  const AddAddressScreen({
    super.key,
    required this.addressID,
    required this.countryName,
    required this.mobileNumber,
    required this.flatHouseNumber,
    required this.areaStreet,
    required this.pinCode,
    required this.city,
    required this.state,
    required this.userID,
  });

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController countryNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController flatHouseNumberController = TextEditingController();
  TextEditingController areaStreetController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  String? selectedState;

  @override
  void initState() {
    super.initState();
    countryNameController.text = widget.countryName;
    mobileNumberController.text = widget.mobileNumber;
    flatHouseNumberController.text = widget.flatHouseNumber;
    areaStreetController.text = widget.areaStreet;
    pinCodeController.text = widget.pinCode;
    cityController.text = widget.city;
    selectedState = widget.state;
  }

  final List<String> statesList = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add New Address',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: countryNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Country Name is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Country/Region',
                obscureText: false,
              ),
              CustomTextFormField(
                controller: mobileNumberController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Mobile Number is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Mobile Number',
                obscureText: false,
              ),
              CustomTextFormField(
                controller: flatHouseNumberController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Flat, House no., Building, Company, Apartment is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Flat, House no., Building, Company, Apartment',
                obscureText: false,
              ),
              CustomTextFormField(
                controller: areaStreetController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Area, Street, Village is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Area, Street, Village',
                obscureText: false,
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
              ),
              // In your build method
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  validator: (value) {
                    if (value == null) {
                      return "Please select a State";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: CupertinoColors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: CupertinoColors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Ensure that the selectedState is valid or null
                  value:
                      statesList.contains(selectedState) ? selectedState : null,
                  hint: const Text(
                    'Select State',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  items: statesList.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 5),
              CustomButton(
                backgroundColor: kAppBarColor,
                textColor: Colors.white,
                buttonName: 'Add Address',
                onPressed: addAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addAddress() async {
    try {
      int? lastID =
          await getLastID(collectionName: "address", primaryKey: "addressID");
      int newID = (lastID ?? 0) + 1; // Generate next ID
      String newIDString =
          newID.toString().padLeft(3, '0'); // Convert to zero-padded string
      final userID = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance
          .collection('address')
          .doc(newIDString)
          .set({
        "addressID": newIDString, // Store as a string
        'Country': countryNameController.text.trim(),
        'PhoneNo': mobileNumberController.text.trim(),
        'HouseNo':
            flatHouseNumberController.text.trim(),
        'Area': areaStreetController.text.trim(),
        'PinCode': pinCodeController.text.trim(),
        'City': cityController.text.trim(),
        'State': selectedState,
        'userID': userID,
        'createdAt': getFormattedDateTime(),
        'modifiedAt': getFormattedDateTime(),
      });
      Navigator.pop(context); // Go back to the previous screen after saving
    } catch (e) {
      throw ('Error adding address: $e');
    }
  }

}