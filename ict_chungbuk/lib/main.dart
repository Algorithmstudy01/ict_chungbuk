import 'package:flutter/material.dart';
import 'start_section.dart';  // Import the start section

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartSection(),  // Start the app with StartSection
    );
  }
}