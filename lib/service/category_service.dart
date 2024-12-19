import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:link/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addCategory(CategoryModel category, File imageFile) async {
    // Upload image and get URL
    final imageUrl = await _uploadImageFile(imageFile);

    // Save category to Firestore
    await _firestore.collection('categories').add({
      'name': category.name,
      'description': category.description,
      'imageUrl': imageUrl,
      'createdAt': category.createdAt,
      'modifiedAt': category.modifiedAt,
      'disabled': category.disabled,
    });
  }

  Future<void> addCategoryWithBytes(CategoryModel category, Uint8List imageBytes) async {
    // Upload image and get URL
    final imageUrl = await _uploadImageBytes(imageBytes);

    // Save category to Firestore
    await _firestore.collection('categories').add({
      'name': category.name,
      'description': category.description,
      'imageUrl': imageUrl,
      'createdAt': category.createdAt,
      'modifiedAt': category.modifiedAt,
      'disabled': category.disabled,
    });
  }

  // Update category with the option to keep the current image
  Future<void> updateCategory(String id, CategoryModel category, File? imageFile) async {
    String imageUrl = category.imageUrl; // Default to existing image URL

    // If a new image is provided, upload it and get the new URL
    if (imageFile != null) {
      imageUrl = await _uploadImageFile(imageFile);
    }

    // Update category in Firestore with the new or existing image URL
    await _firestore.collection('categories').doc(id).update({
      'name': category.name,
      'description': category.description,
      'imageUrl': imageUrl,
      'modifiedAt': category.modifiedAt,
      'disabled': category.disabled,
    });
  }

  // Update category with image bytes (same logic as File update)
  Future<void> updateCategoryWithBytes(String id, CategoryModel category, Uint8List? imageBytes) async {
    String imageUrl = category.imageUrl; // Default to existing image URL

    // If new image bytes are provided, upload them and get the new URL
    if (imageBytes != null) {
      imageUrl = await _uploadImageBytes(imageBytes);
    }

    // Update category in Firestore with the new or existing image URL
    await _firestore.collection('categories').doc(id).update({
      'name': category.name,
      'description': category.description,
      'imageUrl': imageUrl,
      'modifiedAt': category.modifiedAt,
      'disabled': category.disabled,
    });
  }

  // Upload image from File and return the URL
  Future<String> _uploadImageFile(File imageFile) async {
    final ref = _storage.ref().child('categories/${DateTime.now().toIso8601String()}');
    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  // Upload image from bytes and return the URL
  Future<String> _uploadImageBytes(Uint8List imageBytes) async {
    final ref = _storage.ref().child('categories/${DateTime.now().toIso8601String()}');
    final uploadTask = await ref.putData(imageBytes);
    return await uploadTask.ref.getDownloadURL();
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();
  }

  // Read all categories
  Future<List<CategoryModel>> getCategories() async {
    QuerySnapshot snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }
}
