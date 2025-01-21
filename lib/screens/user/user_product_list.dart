import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_textfiled.dart';
import 'package:link/screens/user/product_detail.dart';
import '../../components/custom_circular_progress_indicator.dart';
import '../../constants/color.dart';

class UserProductList extends StatefulWidget {
  const UserProductList({super.key});

  @override
  State<UserProductList> createState() => _UserProductListState();
}

class _UserProductListState extends State<UserProductList> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: CupertinoColors.white),
        backgroundColor: kAppBarColor,
        title: const Text(
          'Products',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: searchController,
                    prefixIcon: const Icon(Icons.search),
                    obscureText: false,
                    keyboardType: TextInputType.name,
                    labelText: "Search Products",
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    validator: (value) => null,
                  ),
                ),
                const SizedBox(width: 8),
                _buildIcon(Icons.shopping_cart_outlined),
                const SizedBox(width: 8),
                _buildIcon(Icons.notifications_none),
              ],
            ),

            // Grid View for Products
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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

                  // Filter the data based on the search query
                  List<DocumentSnapshot> filteredDocs = snapshot.data!.docs
                      .where((doc) => (doc.data() as Map<String, dynamic>)['productName']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery))
                      .toList();

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return ProductCard(data: data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProductCard({Key? key, required this.data}) : super(key: key);

  Future<String> getCategoryName(String categoryID) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('category')
          .where('categoryID', isEqualTo: categoryID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final categoryData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
        return categoryData?["categoryName"] ?? "Unknown Category";
      } else {
        return "Unknown Category";
      }
    } catch (e) {
      return "Error fetching category";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(productData: data),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Flexible(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
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
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            // Details Section
            Container(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['productName'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<String>(
                    future: getCategoryName(data['categoryID']),
                    builder: (context, snapshot) {
                      return Text(
                        snapshot.data ?? "Loading...",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${data['price']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (data['discount'] != null)
                    Text(
                      '${data['discount']}% OFF',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}