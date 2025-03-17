import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/components/dateFormat.dart';

import '../../components/custom_circular_progress_indicator.dart';
import '../../constants/color.dart';

class OrdersList extends StatefulWidget {
  const OrdersList({super.key});

  @override
  State<OrdersList> createState() => _OrdersState();
}

class _OrdersState extends State<OrdersList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: CupertinoColors.white,
        ),
        backgroundColor: kAppBarColor,
        title: const Text(
          'Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CustomCupertinoActivityIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          // 🔹 Filter out empty documents
          var orders = snapshot.data!.docs
              .where((doc) => (doc.data() as Map<String, dynamic>)['orderID'] != null)
              .toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;

              Timestamp? createdTimestamp = order['created'];
              String createdDate = createdTimestamp != null
                  ? getFormattedDateTime(dateToFormat: createdTimestamp.toDate())
                  : "No Date";

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text("Order ID: ${order['orderID']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Status: ${order['orderStatus']}"),
                      Text("Total Price: ₹${order['price']}"),
                      Text("Created: $createdDate"),
                      Text("User ID: ${order['userID']}"),
                      Text("Products: ${order['productIDs']}"),
                      Text("Quantities: ${order['quantities']}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
