import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // import your homepage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // hide debug banner
      title: 'Contacts App',
      theme: ThemeData(
        primarySwatch: Colors.blue,

        // ✅ Apply Poppins globally
        fontFamily: 'Poppins',
      ),
      home: HomePage(), // go straight to HomePage
    );
  }
}
