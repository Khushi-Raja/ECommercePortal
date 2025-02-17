import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/custom_button.dart';
import '../../components/custom_circular_progress_indicator.dart';
import '../../components/custom_snackbar.dart';
import '../../components/custom_textfiled.dart';
import '../../components/dateFormat.dart';
import '../../constants/color.dart';
import '../../constants/generate_id.dart';

class AddProduct extends StatefulWidget {
  final String productID;
  final String productName;
  final String description;
  final double price;
  final String code;
  final String displayImage;
  final double discount;
  final String categoryID;

  const AddProduct({
    super.key,
    required this.productID,
    required this.productName,
    required this.description,
    required this.price,
    required this.code,
    required this.displayImage,
    required this.discount,
    required this.categoryID,
  });

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController productNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  File? imageFile;
  Uint8List? _imageBytes; // For web image handling

  String? selectedCategoryId; // To store the selected category ID
  List<Map<String, dynamic>> categories = []; // List to hold categories
  bool isLoading =
      true; // For showing loading indicator while fetching categories

  @override
  void initState() {
    super.initState();
    productNameController.text = widget.productName;
    descriptionController.text = widget.description;
    priceController.text = widget.price.toString();
    codeController.text = widget.code;
    discountController.text = widget.discount.toString();
    selectedCategoryId =
        widget.categoryID; // Initialize with the passed category ID
    fetchCategories();
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
        iconTheme: const IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          widget.productID.isEmpty ? 'Add Product' : 'Update Product',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: 150, // Width of the square box
                  height: 150, // Height of the square box
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    border: Border.all(color: Colors.grey.shade400, width: 2), // Border style
                    image: _imageBytes != null || imageFile != null || widget.productID.isNotEmpty
                        ? DecorationImage(
                      image: _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : imageFile != null
                          ? FileImage(imageFile!)
                          : NetworkImage(widget.displayImage) as ImageProvider,
                      fit: BoxFit.cover, // Fill the box with the image
                    )
                        : null,
                  ),
                  child: (_imageBytes == null && imageFile == null && widget.productID.isEmpty)
                      ? const Center(
                    child: Icon(Icons.camera_alt, color: Colors.grey)
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: productNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Product is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Product Name',
                obscureText: false,
              ),
              CustomTextFormField(
                controller: descriptionController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Product Description is required";
                  }
                  return null;
                },
                maxLines: 5,
                keyboardType: TextInputType.name,
                labelText: 'Product Description',
                obscureText: false,
              ),
              CustomTextFormField(
                controller: priceController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Price is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                labelText: 'Product Price',
                obscureText: false,
              ),
              CustomTextFormField(
                controller: codeController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Code is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Product Code',
                obscureText: false,
              ),
              CustomTextFormField(
                controller: discountController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Discount is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Product Discount',
                obscureText: false,
              ),

              // Dropdown code
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('category')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child:
                            CustomCupertinoActivityIndicator()); // Show loading indicator until data is fetched
                  }
                  List<DocumentSnapshot> categoryDocs = snapshot.data!.docs;
                  List<Map<String, String>> categories =
                      categoryDocs.map((doc) {
                    return {
                      'id': doc['categoryID'].toString(),
                      // Assuming 'id' and 'name' fields are available in Firestore
                      'name': doc['categoryName'].toString(),
                    };
                  }).toList();

                  // Ensure that the selectedCategoryId is valid or null
                  String? dropdownValue = categories.any(
                          (category) => category['id'] == selectedCategoryId)
                      ? selectedCategoryId
                      : null;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue,
                      hint: const Text('Select Category', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'],
                          child: Text(category['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Please select a category";
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
                    ),
                  );
                },
              ),

              const SizedBox(height: 5),
              CustomButton(
                buttonName: widget.productName.isNotEmpty
                    ? 'Update Product'
                    : 'Add Product',
                onPressed: submit,
                backgroundColor: kAppBarColor,
                textColor: CupertinoColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submit() async {
    if (formKey.currentState!.validate()) {
      try {
        if (widget.productName.isNotEmpty) {
          if (kIsWeb) {
            await updateProductWithBytes();
          } else {
            await updateProduct();
          }
          SnackBarUtil.show(
              context: context, message: "Product Updated Successfully");
        } else {
          if (kIsWeb) {
            await addProductWithBytes();
          } else {
            await addProduct();
          }
          SnackBarUtil.show(
              context: context, message: "Product Added Successfully");
        }
        Navigator.of(context).pop();
      } catch (e) {
        SnackBarUtil.show(context: context, message: "Error: $e");
      }
    }
  }

  Future<void> addProduct() async {
    try {
      int? lastID = await getLastID(collectionName: "product", primaryKey: "productID");
      print("Last ID: $lastID");

      int newID = (lastID ?? 0) + 1; // Generate next ID
      String newIDString = newID.toString().padLeft(3, '0'); // Convert to zero-padded string

      print("New ID: $newIDString");

      final productImageURL = await uploadImageFile(imageFile!);

      await FirebaseFirestore.instance.collection('product').doc(newIDString).set({
        "productID": newIDString, // Store as a string
        'productName': productNameController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': priceController.text.trim(),
        'code': codeController.text.trim(),
        'displayImage': productImageURL,
        'discount': discountController.text.trim(),
        "categoryID": selectedCategoryId,
        'createdAt': getFormattedDateTime(),
        'modifiedAt': getFormattedDateTime(),
        'isDisabled': false,
      });
    } catch (e) {
      throw ('Error adding product: $e');
    }
  }

  Future<void> addProductWithBytes() async {
    try {
      int? lastID =
          await getLastID(collectionName: "product", primaryKey: "productID");
      int newID = (lastID ?? 0) + 1; // Use a fallback value if lastID is null
      String newIDString = newID.toString().padLeft(3, '0'); // Convert to zero-padded string
      final productImageURL = await uploadImageBytes(_imageBytes!);
      await FirebaseFirestore.instance.collection('product').doc(newIDString).set({
        "productID": newIDString,
        'productName': productNameController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': priceController.text.trim(),
        'code': codeController.text.trim(),
        'displayImage': productImageURL,
        'discount': discountController.text.trim(),
        "categoryID": selectedCategoryId,
        'createdAt': getFormattedDateTime(),
        'modifiedAt': getFormattedDateTime(),
        'isDisabled': false,
      });
    } catch (e) {
      throw ('Error adding product: $e');
    }
  }

  Future<void> updateProduct() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('product')
          .where('productID', isEqualTo: widget.productID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final productSnapShot = querySnapshot.docs.first;
        final productData = productSnapShot.data() as Map<String, dynamic>?;

        if (productData != null) {
          await productSnapShot.reference.update({
            'productName': productNameController.text,
            'description': descriptionController.text,
            'price': priceController.text.trim(),
            'code': codeController.text.trim(),
            'discount': discountController.text.trim(),
            "categoryID": selectedCategoryId,
            'modifiedAt': getFormattedDateTime(),
            'isDisabled': false,
          });
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Product with ID ${widget.productID} not found.');
      }
    } catch (e) {
      throw ('Error updating Product details: $e');
    }
  }

  Future<void> updateProductWithBytes() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('product')
          .where('productID', isEqualTo: widget.productID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final productSnapShot = querySnapshot.docs.first;
        final productData = productSnapShot.data() as Map<String, dynamic>?;

        if (productData != null) {
          String? productImageURL =
              widget.displayImage; // Retain current image URL

          // Check if there's a new image to upload
          if (_imageBytes != null) {
            productImageURL = await uploadImageBytes(_imageBytes!);
          } else if (imageFile != null) {
            productImageURL = await uploadImageFile(imageFile!);
          }

          // Update the product details in Firestore
          await productSnapShot.reference.update({
            'productName': productNameController.text,
            'description': descriptionController.text.trim(),
            'price': priceController.text.trim(),
            'code': codeController.text.trim(),
            'discount': discountController.text.trim(),
            "categoryID": selectedCategoryId,
            'displayImage': productImageURL,
            'modifiedAt': getFormattedDateTime(),
            'isDisabled': false,
          });
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Product with ID ${widget.productID} not found.');
      }
    } catch (e) {
      throw ('Error updating product with bytes: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('category').get();

      setState(() {
        categories = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['categoryName'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (kIsWeb) {
        // For web: use image bytes
        final Uint8List imageBytes = await pickedImage.readAsBytes();
        setState(() {
          _imageBytes = imageBytes; // Store Uint8List for web
          imageFile = null; // Clear the File reference
        });
      } else {
        // For mobile: use the File
        setState(() {
          imageFile = File(pickedImage.path);
          _imageBytes = null; // Clear the Uint8List reference
        });
      }
    }
  }

  // Upload image from File and return the URL
  Future<String> uploadImageFile(File imageFile) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('product/${DateTime.now().toIso8601String()}');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  // Upload image from bytes and return the URL
  Future<String> uploadImageBytes(Uint8List imageBytes) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('product/${DateTime.now().toIso8601String()}');
    final uploadTask = await ref.putData(imageBytes);
    return await uploadTask.ref.getDownloadURL();
  }
}