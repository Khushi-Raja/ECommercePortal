import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:link/screens/user/shipping_address_screen.dart';
import '../../components/custom_button.dart';
import '../../constants/color.dart';

class CheckOutScreen extends StatefulWidget {
  final double originalTotal;
  final double discountTotal;
  final double finalAmount;

  const CheckOutScreen(
      {super.key,
      required this.originalTotal,
      required this.discountTotal,
      required this.finalAmount});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: CupertinoColors.white),
        backgroundColor: kAppBarColor,
        title: const Text(
          "Checkout",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(128, 128, 128, 0.1),
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Order Summary",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    _buildPricingRow('Original Total', widget.originalTotal),
                    _buildPricingRow('Discount Total', -widget.discountTotal),
                    const Divider(height: 20, thickness: 1),
                    _buildPricingRow('Final Amount', widget.finalAmount,
                        isFinal: true),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(128, 128, 128, 0.1),
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return ShippingAddressScreen(
                                  totalAmount: widget.finalAmount);
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Shipping Address",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              CustomButton(
                onPressed: () {},
                backgroundColor: kAppBarColor,
                textColor: Colors.white,
                buttonName: 'Pay Now ₹${widget.finalAmount.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingRow(String label, double value, {bool isFinal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.w600 : FontWeight.normal,
              color: isFinal ? Colors.green : Colors.grey.shade700,
            ),
          ),
          Text(
            '₹${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isFinal ? 16 : 14,
              fontWeight: isFinal ? FontWeight.w600 : FontWeight.normal,
              color: value < 0
                  ? Colors.red
                  : (isFinal ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
