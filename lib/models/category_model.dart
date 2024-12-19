import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool disabled;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.modifiedAt,
    required this.disabled,
  });

  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      modifiedAt: (data['modifiedAt'] as Timestamp).toDate(),
      disabled: data['disabled'],
    );
  }
}