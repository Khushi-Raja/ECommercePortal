import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_circular_progress_indicator.dart';
import '../../components/dateFormat.dart';
import '../../constants/color.dart';

class MyOrder extends StatefulWidget {
  const MyOrder({super.key});

  @override
  State<MyOrder> createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  List<Map<String, dynamic>> ordersList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  Future<void> getOrders() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userID', isEqualTo: user.uid)
          .get();

      if (orderSnapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      List<Map<String, dynamic>> orders = [];
      List<String> productIDs = [];

      for (var doc in orderSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Timestamp? createdTime = data['created'];
        String createdDate = createdTime != null
            ? getFormattedDateTime(dateToFormat: createdTime.toDate())
            : "No Date";

        List<String> pIDs = data['productIDs'].toString().split(',');
        List<String> quantities = data['quantities'].toString().split(',');
        productIDs.addAll(pIDs);

        orders.add({
          'id': doc.id,
          'createdDate': createdDate,
          'productIDs': pIDs,
          'quantities': quantities,
          'orderStatus': data['orderStatus'] ?? 'Unknown',
        });
      }

      Map<String, Map<String, dynamic>> products =
          await getProductDetails(productIDs);

      for (var order in orders) {
        List<Map<String, dynamic>> productsList = [];
        for (int i = 0; i < order['productIDs'].length; i++) {
          String pID = order['productIDs'][i];
          if (products.containsKey(pID)) {
            productsList.add({
              ...products[pID]!,
              'quantity': order['quantities'][i],
            });
          }
        }
        order['products'] = productsList;
      }

      setState(() {
        ordersList = orders;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, Map<String, dynamic>>> getProductDetails(
      List<String> productIDs) async {
    Map<String, Map<String, dynamic>> productData = {};
    if (productIDs.isEmpty) return productData;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('product')
          .where('productID', whereIn: productIDs)
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        productData[data['productID']] = {
          'name': data['productName'] ?? "Unknown Product",
          'image': data['displayImage'] ?? "https://via.placeholder.com/50",
          'price': data['price'] ?? 0,
        };
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }

    return productData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: CupertinoColors.white),
        backgroundColor: kAppBarColor,
        title: const Text(
          'My Orders',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CustomCupertinoActivityIndicator())
          : ordersList.isEmpty
              ? const Center(child: Text("No orders found."))
              : ListView.builder(
                  itemCount: ordersList.length,
                  itemBuilder: (context, index) {
                    var order = ordersList[index];
                    var products =
                        order['products'] as List<Map<String, dynamic>>;
                    return Column(
                      children: products.map((product) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromRGBO(128, 128, 128, 0.1),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      product['image'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${product['quantity']} x ₹${product['price']}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "${order['createdDate']}",
                                          style: const TextStyle(
                                            color: Color(0xFF9E9E9E),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${order['orderStatus']}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFFFFA726),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
    );
  }
}