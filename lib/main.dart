import 'package:flutter/material.dart';
import 'package:mobile_quanlykhachsan/screens/home_screen.dart';
import 'package:mobile_quanlykhachsan/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/booking_cart_provider.dart';
void main() {
  runApp(
    // 2. Bọc ứng dụng trong MultiProvider
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => BookingCartProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Khách Sạn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}