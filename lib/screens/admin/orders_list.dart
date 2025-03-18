import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:link/components/dateFormat.dart';

import '../../components/custom_circular_progress_indicator.dart';
import '../../constants/color.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({super.key});

  @override
  State<OrdersList> createState() => _OrdersState();
}

class _OrdersState extends State<OrdersList> {
  List<Map<String, dynamic>> ordersList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  Future<void> getOrders() async {
    try {
      QuerySnapshot orderSnapshot =
      await FirebaseFirestore.instance.collection('orders').get();

      if (orderSnapshot.docs.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      List<Map<String, dynamic>> orders = [];
      List<String> productIDs = [];
      List<String> userIDs = [];

      for (var doc in orderSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        Timestamp? createdTime = data['created'];
        String createdDate = createdTime != null
            ? getFormattedDateTime(dateToFormat: createdTime.toDate())
            : "No Date";

        List<String> pIDs = data['productIDs'].toString().split(',');
        List<String> quantities = data['quantities'].toString().split(',');
        productIDs.addAll(pIDs);
        userIDs.add(data['userID'] ?? 'Unknown'); // Collect user IDs

        orders.add({
          'id': doc.id,
          'userID': data['userID'] ?? 'Unknown',
          'createdDate': createdDate,
          'productIDs': pIDs,
          'quantities': quantities,
          'orderStatus': data['orderStatus'] ?? 'Unknown',
        });
      }

      Map<String, Map<String, dynamic>> products =
      await getProductDetails(productIDs);
      Map<String, String> userNames =
      await getUserDetails(userIDs); // Fetch user names

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
        order['userName'] = userNames[order['userID']] ??
            'Unknown User'; // Add user name to order
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

  Future<Map<String, String>> getUserDetails(List<String> userIDs) async {
    Map<String, String> userData = {};
    if (userIDs.isEmpty) return userData;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIDs)
          .get();

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        userData[doc.id] =
            data['name'] ?? "Unknown User"; // Store user name by user ID
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    }

    return userData;
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
          'Orders',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CustomCupertinoActivityIndicator())
          : ordersList.isEmpty
          ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined, // Cart empty icon
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 10), // Spacing between icon and text
              const Text(
                "No orders yet!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ))
          : ListView.builder(
        itemCount: ordersList.length,
        itemBuilder: (context, index) {
          var order = ordersList[index];
          var products =
          order['products'] as List<Map<String, dynamic>>;
          return Column(
            children: products.map((product) {
              return Slidable(
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        outlinedButtonTheme:
                        const OutlinedButtonThemeData(
                          style: ButtonStyle(
                            iconColor: WidgetStatePropertyAll(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                      child: SlidableAction(
                        onPressed: (context) {},
                        backgroundColor: Colors.lightBlue,
                        icon: Icons.edit,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        outlinedButtonTheme:
                        const OutlinedButtonThemeData(
                          style: ButtonStyle(
                            iconColor: WidgetStatePropertyAll(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                      child: SlidableAction(
                        onPressed: (context) {},
                        backgroundColor: Colors.red,
                        icon: Icons.delete_rounded,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
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
                                  "Ordered on ${order['createdDate']}",
                                  style: const TextStyle(
                                    color: Color(0xFF9E9E9E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${order['orderStatus']}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: order['orderStatus'] ==
                                            'Pending'
                                            ? const Color(0xFFFFA726)
                                            : order['orderStatus'] ==
                                            'Delivered'
                                            ? Colors.green
                                            : Colors.transparent,
                                        // Default color if not Pending or Delivered
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "${order['userName']}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
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
