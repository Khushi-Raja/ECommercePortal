import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_textfiled.dart';
import 'package:link/screens/user/checkout/cart_screen.dart';
import 'package:link/screens/user/product/product_detail.dart';
import '../../../components/custom_circular_progress_indicator.dart';
import '../../../constants/color.dart';

class UserProductList extends StatefulWidget {
  const UserProductList({super.key});

  @override
  State<UserProductList> createState() => _UserProductListState();
}
class _UserProductListState extends State<UserProductList> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);
  String _searchQuery = "";
  late Future<Map<String, String>> _categoryMap;

  @override
  void initState() {
    super.initState();
    _categoryMap = _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _loadCategories() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('category').get();

      return {
        for (var doc in querySnapshot.docs)
          doc['categoryID']: doc['categoryName'] ?? 'Unnamed Category'
      };
    } catch (e) {
      debugPrint("Error loading categories: $e");
      return {};
    }
  }

  String _getCategoryName(String categoryID, Map<String, String> categories) {
    return categories[categoryID] ?? 'Unknown Category';
  }

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
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _searchController,
                    prefixIcon: const Icon(Icons.search),
                    obscureText: false,
                    keyboardType: TextInputType.name,
                    labelText: "Search Products or Categories",
                    onChanged: (value) {
                      _searchDebouncer.run(() {
                        setState(
                            () => _searchQuery = value.trim().toLowerCase());
                      });
                    },
                    validator: (value) => null,
                  ),
                ),
                const SizedBox(width: 8),
                _buildIcon(
                  Icons.shopping_cart_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  ),
                ),
                const SizedBox(width: 8),
                _buildIcon(Icons.notifications_none),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<Map<String, String>>(
                future: _categoryMap,
                builder: (context, categorySnapshot) {
                  if (!categorySnapshot.hasData) {
                    return const CustomCupertinoActivityIndicator();
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('product')
                        .orderBy('productName')
                        .snapshots(),
                    builder: (context, productSnapshot) {
                      if (!productSnapshot.hasData) {
                        return const CustomCupertinoActivityIndicator();
                      }

                      final products = productSnapshot.data!.docs;
                      return _buildProductGrid(
                        products: products,
                        categories: categorySnapshot.data!,
                      );
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

  Widget _buildProductGrid(
      {required List<QueryDocumentSnapshot> products,
      required Map<String, String> categories}) {
    final filteredProducts = _searchQuery.isEmpty
        ? products
        : products.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final productName =
                data['productName']?.toString().toLowerCase() ?? '';
            final categoryName =
                _getCategoryName(data['categoryID'], categories).toLowerCase();
            return productName.contains(_searchQuery) ||
                categoryName.contains(_searchQuery);
          }).toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final doc = filteredProducts[index];
        final data = doc.data() as Map<String, dynamic>;
        final categoryID = data['categoryID']?.toString() ?? '';
        final categoryName = _getCategoryName(categoryID, categories);
        return ProductCard(
          data: data,
          categoryName: categoryName,
        );
      },
    );
  }

  Widget _buildIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String categoryName;

  const ProductCard(
      {super.key, required this.data, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetail(productData: data),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    child: Image.network(
                      data['displayImage'],
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                            child: CustomCupertinoActivityIndicator());
                      },
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
                      child:
                          const Icon(Icons.favorite_border, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
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
                  Text(
                    categoryName,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
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
class Debouncer {
  final int milliseconds;
  Timer? _timer;
  Debouncer({required this.milliseconds});
  void run(VoidCallback action) {
    _timer?.cancel(); // Cancel the existing timer
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
  void cancel() => _timer?.cancel();
}