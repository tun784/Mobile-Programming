import 'package:first_ui/Dialog/demoDialog.dart';
import 'package:first_ui/ListView_and_GridView/demoListView.dart';
import 'package:first_ui/ListView_and_GridView/demoGridView.dart';
import 'package:first_ui/Scaffold/demoScaffold.dart';
import 'package:first_ui/screens/test_statefull_widget.dart';
import 'package:first_ui/simplistic_calculator/calculator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
void main() {
  runApp(DemoApp());
}
class DemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DemoGridView(),
    );
  }
}