import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:link/admin_screen/product/add_product.dart';
import 'package:link/admin_screen/product/product_list.dart';
import 'package:link/splash/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      home: ProductList(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF-Pro',
      ),
    ),
  );
}
