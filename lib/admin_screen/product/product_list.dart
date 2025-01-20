import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/admin_screen/product/add_product.dart';
import '../../components/custom_circular_progress_indicator.dart';
import '../../components/custom_confirmation_popup.dart';
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

          // List fetched from FireStore, already sorted as per our query
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
                  data['displayImage'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (String value) {
                    if (value == 'Edit') {
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
                    }
                    else if (value == 'Delete') {
                      ConfirmationPopup.show(
                        context: context,
                        title: 'Delete Confirmation',
                        content: 'Are you sure you want to delete this product?',
                        yesFunction: () {
                          FirebaseFirestore.instance
                              .collection('product')
                              .doc(document.id)
                              .delete()
                              .then((_) {
                            Navigator.pop(context, true); // Close the dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Product deleted successfully!')),
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
                  data['productName'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (data['description'] != null)
                  Text(
                    data['description']!,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text("No Ratings"),
                    const Spacer(),
                    if (data['discount'] != null)
                      Text(
                        '${data['discount']}% OFF',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),
                Row(
                  children: [
                    if (!data['isDisabled'])
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Available',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      '₹${data['price']}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}