import 'package:first_ui/screens/test_statefull_widget.dart';
import 'package:first_ui/simplistic_calculator/calculator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(DemoApp());
}
class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalculatorApp(),
    );
  }
}