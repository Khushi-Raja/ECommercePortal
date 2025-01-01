import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/admin_screen/product/add_product.dart';

import '../../components/custom_circular_progress_indicator.dart';
import '../../constants/color.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: const Text(
          'Product List',
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
            .collection('product')
            .orderBy('productName')
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
              builder: (context) => const AddProduct(
                  productID: '',
                  productName: '',
                  description: '',
                  price: 0.0,
                  code: '',
                  displayImage: '',
                  discount: 0.0,
                  categoryID: ''),
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
            // Circular image for the product
            ClipOval(
              child: Image.network(
                data['displayImage'],
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
                    data['productName'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['description'] ?? "No description available",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),
                  Text(
                    data['price'] ?? "No price available",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['code'] ?? "No code available",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Text(
                    data['discount'] ?? "No discount available",
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
                    String productID = data['productID'];
                    String productName = data['productName'];
                    String description = data['description'];
                    double price = double.tryParse(data['price'].toString()) ?? 0.0;
                    String code = data['code'];
                    double discount = double.tryParse(data['discount']?.toString() ?? '0') ?? 0.0;
                    String displayImage = data['displayImage'];
                    String categoryID = data['categoryID'];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProduct(
                          productID: productID,
                          productName: productName,
                          description: description,
                          price: price,
                          code: code,
                          displayImage: displayImage,
                          discount: discount,
                          categoryID: categoryID,
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
                        .collection('product')
                        .doc(document.id)
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
