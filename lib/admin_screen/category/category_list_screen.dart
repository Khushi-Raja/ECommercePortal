import 'package:flutter/material.dart';
import 'package:link/models/category_model.dart';
import 'package:link/service/category_service.dart';
import 'category_form_screen.dart';

class CategoryListScreen extends StatefulWidget {
  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final _categoryService = CategoryService();
  late Future<List<CategoryModel>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  void _fetchCategories() {
    setState(() {
      _categoriesFuture = _categoryService.getCategories();
    });
  }

  void _navigateToForm({CategoryModel? category}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CategoryFormScreen(
        category: category,
        refreshCategories: _fetchCategories,
      ),
    ));
  }

  void _deleteCategory(String id) async {
    await _categoryService.deleteCategory(id);
    _fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Categories',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange, // New color scheme
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              splashColor: Colors.transparent, // Remove splash effect
              highlightColor: Colors.transparent, // Remove highlight effect
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _fetchCategories,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<CategoryModel>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No categories available.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          final categories = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two cards per row
              childAspectRatio: 0.75, // Adjust height-to-width ratio
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return Card(
                elevation: 4,
                shadowColor: Colors.teal.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Section
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: category.imageUrl != null &&
                                category.imageUrl!.isNotEmpty
                            ? Image.network(
                                category.imageUrl!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  );
                                },
                              )
                            : Container(
                                color: Colors.teal.withOpacity(0.1),
                                child: const Center(
                                  child: Icon(
                                    Icons.category,
                                    size: 50,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    // Content Section with Menu Button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category Name
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Three-dot Menu
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.black54,
                            ),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _navigateToForm(category: category);
                              } else if (value == 'delete') {
                                _deleteCategory(category.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit, color: Colors.teal),
                                  title: Text('Edit'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  title: Text('Delete'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Description Section
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, bottom: 8.0),
                      child: Text(
                        category.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange, // Updated button color
        onPressed: () {
          _navigateToForm();
        },
        tooltip: 'Add Category',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
