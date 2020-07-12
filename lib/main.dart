import 'package:ddbusinessside/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DripAndDrizzle());
}
class DripAndDrizzle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
