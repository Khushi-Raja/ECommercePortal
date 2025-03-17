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

      Map<String, Map<String, dynamic>> products = await getProductDetails(productIDs);

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

  Future<Map<String, Map<String, dynamic>>> getProductDetails(List<String> productIDs) async {
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: CupertinoColors.white),
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
          var products = order['products'] as List<Map<String, dynamic>>;

          return Column(
            children: products.map((product) {
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(
                    product['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.network("https://via.placeholder.com/50"),
                  ),
                  title: Text(product['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Price: \$${product['price']}"),
                      Text("Quantity: ${product['quantity']}"),
                      Text("Created: ${order['createdDate']}"),
                      Text("Status: ${order['orderStatus']}"),
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
