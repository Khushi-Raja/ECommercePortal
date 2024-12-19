import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link/models/category_model.dart';
import 'package:link/service/category_service.dart';
import 'package:flutter/foundation.dart';
import 'package:link/widgets/my_button.dart';
import 'package:link/widgets/my_textfield.dart';

class CategoryFormScreen extends StatefulWidget {
  final CategoryModel? category;
  final VoidCallback refreshCategories;

  const CategoryFormScreen({this.category, required this.refreshCategories});

  @override
  _CategoryFormScreenState createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  Uint8List? _imageBytes; // For web image handling
  bool _isDisabled = false;
  final _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description;
      _isDisabled = widget.category!.disabled;
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      if (kIsWeb) {
        // For web: use image bytes
        final Uint8List imageBytes = await pickedImage.readAsBytes();
        setState(() {
          _imageBytes = imageBytes; // Store Uint8List for web
          _imageFile = null; // Clear the File reference
        });
      } else {
        // For mobile: use the File
        setState(() {
          _imageFile = File(pickedImage.path);
          _imageBytes = null; // Clear the Uint8List reference
        });
      }
    }
  }

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null && _imageBytes == null && widget.category?.imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image.')),
        );
        return;
      }

      final category = CategoryModel(
        id: widget.category?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: widget.category?.imageUrl ?? '',
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
        disabled: _isDisabled,
      );

      if (widget.category == null) {
        if (kIsWeb) {
          await _categoryService.addCategoryWithBytes(category, _imageBytes!);
        } else {
          await _categoryService.addCategory(category, _imageFile!);
        }
      } else {
        if (_imageBytes != null) {
          await _categoryService.updateCategoryWithBytes(category.id, category, _imageBytes);
        } else if (_imageFile != null) {
          await _categoryService.updateCategory(category.id, category, _imageFile);
        } else {
          await _categoryService.updateCategory(category.id, category, null);
        }
      }

      widget.refreshCategories();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.category == null ? 'Add Category' : 'Edit Category',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, width: 100, height: 100)
                        : _imageFile != null
                        ? Image.file(_imageFile!, width: 100, height: 100)
                        : widget.category?.imageUrl != null
                        ? Image.network(widget.category!.imageUrl!, width: 100, height: 100)
                        : Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_a_photo),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _nameController,
                    hintText: "Category Name",
                    obscureText: false,
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  MyTextField(
                    controller: _descriptionController,
                    hintText: "Description",
                    obscureText: false,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          'Disabled:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isDisabled,
                          onChanged: (value) {
                            setState(() {
                              _isDisabled = value;
                            });
                          },
                          activeColor: Colors.orange,
                          inactiveThumbColor: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyButton(
                    onTap: _saveCategory,
                    text: widget.category == null ? 'Create' : 'Update',
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}