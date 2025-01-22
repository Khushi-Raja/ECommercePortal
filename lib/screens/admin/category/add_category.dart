import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link/components/custom_button.dart';
import 'package:link/components/custom_snackbar.dart';
import 'package:link/components/custom_textfiled.dart';
import 'package:link/components/dateFormat.dart';
import 'package:link/constants/color.dart';
import 'package:link/constants/generate_id.dart';

class AddCategory extends StatefulWidget {
  final String categoryID;
  final String categoryName;
  final String categoryDescription;
  final String categoryImage;

  const AddCategory(
      {super.key,
      required this.categoryID,
      required this.categoryName,
      required this.categoryDescription,
      required this.categoryImage});

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController categoryNameController = TextEditingController();
  TextEditingController categoryDescriptionController = TextEditingController();
  File? imageFile;
  Uint8List? _imageBytes; // For web image handling

  @override
  void initState() {
    super.initState();
    categoryNameController.text = widget.categoryName;
    categoryDescriptionController.text = widget.categoryDescription;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: Text(
          widget.categoryID.isEmpty ? 'Add Category' : 'Update Category',
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
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    border: Border.all(color: Colors.grey.shade400, width: 2), // Border style
                    image: _imageBytes != null || imageFile != null || widget.categoryID.isNotEmpty
                        ? DecorationImage(
                      image: _imageBytes != null
                          ? MemoryImage(_imageBytes!)
                          : imageFile != null
                          ? FileImage(imageFile!)
                          : NetworkImage(widget.categoryImage) as ImageProvider,
                      fit: BoxFit.cover, // Fill the box with the image
                    )
                        : null,
                  ),
                  child: (_imageBytes == null && imageFile == null && widget.categoryID.isEmpty)
                      ? const Center(
                    child: Icon(Icons.camera_alt, color: Colors.grey)
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              CustomTextFormField(
                controller: categoryNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Category is required";
                  }
                  return null;
                },
                keyboardType: TextInputType.name,
                labelText: 'Category Name',
                obscureText: false,
              ),
              CustomTextFormField(
                controller: categoryDescriptionController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Category Description is required";
                  }
                  return null;
                },
                maxLines: 5,
                keyboardType: TextInputType.name,
                labelText: 'Category Description',
                obscureText: false,
              ),
              const SizedBox(height: 5),
              CustomButton(
                buttonName: widget.categoryName.isNotEmpty
                    ? 'Update Category'
                    : 'Add Category',
                onPressed: submit,
                backgroundColor: CupertinoColors.black,
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
        if (widget.categoryName.isNotEmpty) {
          if (kIsWeb) {
            await updateCategoryWithBytes();
          } else {
            await updateCategory();
          }
          SnackBarUtil.show(
              context: context, message: "Category Updated Successfully");
        } else {
          if (kIsWeb) {
            await addCategoryWithBytes();
          } else {
            await addCategory();
          }
          SnackBarUtil.show(
              context: context, message: "Category Added Successfully");
        }
        Navigator.of(context).pop();
      } catch (e) {
        SnackBarUtil.show(context: context, message: "Error: $e");
      }
    }
  }

  Future<void> addCategory() async {
    try {
      int? lastID =
          await getLastID(collectionName: "category", primaryKey: "categoryID");
      int newID = lastID! + 1;
      final categoryImageURL = await uploadImageFile(imageFile!);
      await FirebaseFirestore.instance.collection('category').add({
        "categoryID": newID.toString(),
        'categoryName': categoryNameController.text.trim(),
        'categoryDescription': categoryDescriptionController.text.trim(),
        'categoryImage': categoryImageURL,
        'createdAt': getFormattedDateTime(),
        'modifiedAt': getFormattedDateTime(),
        'isDisabled': false,
      });
    } catch (e) {
      throw ('Error adding Category: $e');
    }
  }

  Future<void> addCategoryWithBytes() async {
    try {
      int? lastID =
          await getLastID(collectionName: "category", primaryKey: "categoryID");
      int newID = lastID! + 1;
      final categoryImageURL = await uploadImageBytes(_imageBytes!);
      await FirebaseFirestore.instance.collection('category').add({
        "categoryID": newID.toString(),
        'categoryName': categoryNameController.text.trim(),
        'categoryDescription': categoryDescriptionController.text.trim(),
        'categoryImage': categoryImageURL,
        'createdAt': getFormattedDateTime(),
        'modifiedAt': getFormattedDateTime(),
        'isDisabled': false,
      });
    } catch (e) {
      throw ('Error adding skill: $e');
    }
  }

  Future<void> updateCategory() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('category')
          .where('categoryID', isEqualTo: widget.categoryID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final categorySnapShot = querySnapshot.docs.first;
        final categoryData = categorySnapShot.data() as Map<String, dynamic>?;

        if (categoryData != null) {
          await categorySnapShot.reference.update({
            'categoryName': categoryNameController.text,
            'categoryDescription': categoryDescriptionController.text,
            'modifiedAt': getFormattedDateTime(),
          });
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Category with ID ${widget.categoryID} not found.');
      }
    } catch (e) {
      throw ('Error updating Category details: $e');
    }
  }

  Future<void> updateCategoryWithBytes() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('category')
          .where('categoryID', isEqualTo: widget.categoryID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final categorySnapShot = querySnapshot.docs.first;
        final categoryData = categorySnapShot.data() as Map<String, dynamic>?;

        if (categoryData != null) {
          String? categoryImageURL =
              widget.categoryImage; // Retain current image URL

          // Check if there's a new image to upload
          if (_imageBytes != null) {
            categoryImageURL = await uploadImageBytes(_imageBytes!);
          } else if (imageFile != null) {
            categoryImageURL = await uploadImageFile(imageFile!);
          }

          // Update the category details in Firestore
          await categorySnapShot.reference.update({
            'categoryName': categoryNameController.text.trim(),
            'categoryDescription': categoryDescriptionController.text.trim(),
            'categoryImage': categoryImageURL,
            'modifiedAt': getFormattedDateTime(),
          });
        } else {
          throw ('Document data is null or empty');
        }
      } else {
        throw ('Category with ID ${widget.categoryID} not found.');
      }
    } catch (e) {
      throw ('Error updating category with bytes: $e');
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
        .child('categories/${DateTime.now().toIso8601String()}');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  // Upload image from bytes and return the URL
  Future<String> uploadImageBytes(Uint8List imageBytes) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('categories/${DateTime.now().toIso8601String()}');
    final uploadTask = await ref.putData(imageBytes);
    return await uploadTask.ref.getDownloadURL();
  }
}
