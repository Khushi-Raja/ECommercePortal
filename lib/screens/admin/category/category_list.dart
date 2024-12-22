import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_circular_progress_indicator.dart';
import 'package:link/constants/color.dart';
import 'package:link/screens/admin/category/add_category.dart';

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
        // Directly sorting by 'isDisabled' and 'skillName' in Firestore to reduce manual sorting in the app
        stream: FirebaseFirestore.instance
            .collection('category')
            .orderBy('categoryName')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CustomCupertinoActivityIndicator(),
            );
          }

          // List fetched from Firestore, already sorted as per our query
          List<DocumentSnapshot> skillDocs = snapshot.data!.docs;

          return ListView.builder(
            // Use IndexedListView for better lazy loading with large lists
            itemCount: skillDocs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = skillDocs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return buildCard(context, doc, data);
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
        child: const Icon(
          CupertinoIcons.add,
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
      ),
    );
  }

  Widget buildCard(BuildContext context, DocumentSnapshot document,
      Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular image for the category
            ClipOval(
              child: Image.network(
                data['categoryImage'],
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  CupertinoIcons.photo,
                  size: 40,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(width: 12), // Spacing between image and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['categoryName'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['categoryDescription'] ?? "No description available",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8), // Spacing between details and actions
            // Action buttons for Edit and Delete
            Column(
              children: [
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.pencil,
                    color: CupertinoColors.activeGreen,
                  ),
                  tooltip: "Edit",
                  onPressed: () {
                    String categoryID = data['categoryID'];
                    String categoryName = data['categoryName'];
                    String categoryDescription = data['categoryDescription'];
                    String categoryImage = data['categoryImage'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCategory(
                          categoryID: categoryID,
                          categoryName: categoryName,
                          categoryDescription: categoryDescription,
                          categoryImage: categoryImage,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.trash,
                    color: CupertinoColors.destructiveRed,
                  ),
                  tooltip: "Delete",
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('category')
                        .doc(data['categoryID'])
                        .delete();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
