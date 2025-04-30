import 'package:flutter/material.dart';
import 'package:flutter_ar/ev_map/ev_bottom_navbar.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electro Find',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BottomNav(),
      debugShowCheckedModeBanner: false,
    );
  }
}
