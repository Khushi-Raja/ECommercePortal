import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/constants/color.dart';
import 'package:link/screens/admin/category/add_category.dart';

import '../../../components/custom_circular_progress_indicator.dart';
import '../../../components/custom_confirmation_popup.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: const Text(
          'Category List',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('category')
            .orderBy('categoryName')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CustomCupertinoActivityIndicator());
          }

          List<DocumentSnapshot> categoryDocs = snapshot.data!.docs;


          return ListView.builder(
            // Use IndexedListView for better lazy loading with large lists
            itemCount: categoryDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = categoryDocs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return buildGridItem(context, doc, data);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCategory(
                categoryID: '',
                categoryName: '',
                categoryDescription: '',
                categoryImage: '',
              ),
            ),
          );
        },
        backgroundColor: kAppBarColor,
        child: const Icon(
          CupertinoIcons.add,
          color: CupertinoColors.white,
        ),
      ),
    );
  }

  Widget buildGridItem(BuildContext context, DocumentSnapshot document, Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Image.network(
                  data['categoryImage'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade900),
                  onSelected: (String value) {
                    if (value == 'Edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddCategory(
                            categoryID: data['categoryID'],
                            categoryName: data['categoryName'],
                            categoryDescription: data['categoryDescription'],
                            categoryImage: data['categoryImage'],
                          ),
                        ),
                      );
                    } else if (value == 'Delete') {
                      ConfirmationPopup.show(
                        context: context,
                        title: 'Delete Confirmation',
                        content: 'Are you sure you want to delete this category?',
                        yesFunction: () {
                          FirebaseFirestore.instance
                              .collection('category')
                              .doc(document.id)
                              .delete()
                              .then((_) {
                            Navigator.pop(context, true); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Category deleted successfully!')),
                            );
                          }).catchError((error) {
                            Navigator.pop(context, false); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error deleting category: $error')),
                            );
                          });
                        },
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'Edit',
                        child: ListTile(
                          leading: Icon(CupertinoIcons.pencil, color: CupertinoColors.activeGreen),
                          title: Text('Edit'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: ListTile(
                          leading: Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed),
                          title: Text('Delete'),
                        ),
                      ),
                    ];
                  },
                ),
              ),

            ],
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['categoryName'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (data['categoryDescription'] != null)
                  Text(
                    data['categoryDescription']!,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

}