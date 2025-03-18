import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:link/components/custom_circular_progress_indicator.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../components/custom_snackbar.dart';

class RazorpayPayment extends StatefulWidget {
  final double amount;
  final String orderID;

  const RazorpayPayment({
    super.key,
    required this.amount,
    required this.orderID,
  });

  @override
  State<RazorpayPayment> createState() => _RazorpayPaymentState();
}

class _RazorpayPaymentState extends State<RazorpayPayment> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    WidgetsBinding.instance.addPostFrameCallback((_) => openCheckout());
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': widget.amount * 100,
      'name': 'Link',
      'prefill': {'contact': '1234567890', 'email': 'user@example.com'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    SnackBarUtil.show(
        context: context, message: "Payment Successful: ${response.paymentId}");
    // Update order status
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderID)
        .update({
      'orderStatus': 'Completed',
      'isCompleted': true,
      'modifiedAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context); // Return to previous screen
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    SnackBarUtil.show(
        context: context, message: "Payment Failed: ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    SnackBarUtil.show(
        context: context, message: "External Wallet: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CustomCupertinoActivityIndicator(),
      ),
    );
  }
}
