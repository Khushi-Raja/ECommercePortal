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
                      borderSide: const BorderSide(color: CupertinoColors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  hint: const Text('Select State', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                  items: const [
                    // Add states here
                    DropdownMenuItem(value: 'Andhra Pradesh', child: Text('Andhra Pradesh')),
                    DropdownMenuItem(value: 'Arunachal Pradesh', child: Text('Arunachal Pradesh')),
                    DropdownMenuItem(value: 'Assam', child: Text('Assam')),
                    DropdownMenuItem(value: 'Bihar', child: Text('Bihar')),
                    DropdownMenuItem(value: 'Chhattisgarh', child: Text('Chhattisgarh')),
                    DropdownMenuItem(value: 'Goa', child: Text('Goa')),
                    DropdownMenuItem(value: 'Gujarat', child: Text('Gujarat')),
                    DropdownMenuItem(value: 'Haryana', child: Text('Haryana')),
                    DropdownMenuItem(value: 'Himachal Pradesh', child: Text('Himachal Pradesh')),
                    DropdownMenuItem(value: 'Jharkhand', child: Text('Jharkhand')),
                    DropdownMenuItem(value: 'Karnataka', child: Text('Karnataka')),
                    DropdownMenuItem(value: 'Kerala', child: Text('Kerala')),
                    DropdownMenuItem(value: 'Madhya Pradesh', child: Text('Madhya Pradesh')),
                    DropdownMenuItem(value: 'Maharashtra', child: Text('Maharashtra')),
                    DropdownMenuItem(value: 'Manipur', child: Text('Manipur')),
                    DropdownMenuItem(value: 'Meghalaya', child: Text('Meghalaya')),
                    DropdownMenuItem(value: 'Mizoram', child: Text('Mizoram')),
                    DropdownMenuItem(value: 'Nagaland', child: Text('Nagaland')),
                    DropdownMenuItem(value: 'Odisha', child: Text('Odisha')),
                    DropdownMenuItem(value: 'Punjab', child: Text('Punjab')),
                    DropdownMenuItem(value: 'Rajasthan', child: Text('Rajasthan')),
                    DropdownMenuItem(value: 'Sikkim', child: Text('Sikkim')),
                    DropdownMenuItem(value: 'Tamil Nadu', child: Text('Tamil Nadu')),
                    DropdownMenuItem(value: 'Telangana', child: Text('Telangana')),
                    DropdownMenuItem(value: 'Tripura', child: Text('Tripura')),
                    DropdownMenuItem(value: 'Uttar Pradesh', child: Text('Uttar Pradesh')),
                    DropdownMenuItem(value: 'Uttarakhand', child: Text('Uttarakhand')),
                    DropdownMenuItem(value: 'West Bengal', child: Text('West Bengal')),
                    // Add more states as needed
                  ],
                  onChanged: (value) {
                    selectedState = value!;
                  },
                ),
              ),
              const SizedBox(height: 5),
              CustomButton(
                backgroundColor: kAppBarColor,
                textColor: Colors.white,
                buttonName: 'Save Address',
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
      int? lastID = await getLastID(collectionName: "address", primaryKey: "addressID");
      int newID = (lastID ?? 0) + 1; // Generate next ID
      String newIDString = newID.toString().padLeft(3, '0'); // Convert to zero-padded string
      final userID = FirebaseAuth.instance.currentUser?.uid;
      await FirebaseFirestore.instance.collection('address').doc(newIDString).set({
        "addressID": newIDString, // Store as a string
        'Country/Region': countryNameController.text.trim(),
        'Mobile number': mobileNumberController.text.trim(),
        'Flat, House no., Building, Company, Apartment': flatHouseNumberController.text.trim(),
        'Area, Street, Village': areaStreetController.text.trim(),
        'Pin code': pinCodeController.text.trim(),
        'Town City': cityController.text.trim(),
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

  // Future<void> updateProduct() async {
  //   try {
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('address')
  //         .where('addressID', isEqualTo: widget.addressID)
  //         .get();
  //
  //     if (querySnapshot.docs.isNotEmpty) {
  //       final addressSnapShot = querySnapshot.docs.first;
  //       final addressData = addressSnapShot.data() as Map<String, dynamic>?;
  //
  //       if (addressData != null) {
  //         await addressSnapShot.reference.update({
  //           'Country/Region': countryNameController.text.trim(),
  //           'Mobile number': mobileNumberController.text.trim(),
  //           'Flat, House no., Building, Company, Apartment': flatHouseNumberController.text.trim(),
  //           'Area, Street, Village': areaStreetController.text.trim(),
  //           'Pin code': pinCodeController.text.trim(),
  //           'Town City': cityController.text.trim(),
  //           'State': selectedState,
  //           'modifiedAt': getFormattedDateTime(),
  //         });
  //       } else {
  //         throw ('Document data is null or empty');
  //       }
  //     } else {
  //       throw ('Address with ID ${widget.addressID} not found.');
  //     }
  //   } catch (e) {
  //     throw ('Error updating Address details: $e');
  //   }
  // }
}
