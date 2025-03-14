import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class DemoGridView extends StatelessWidget {
  static int countItem = 30;
  List<String> items = List.generate(countItem, (index) => "Item ${index + 1}");

  getGridView(){
    return GridView.count(
      crossAxisCount: 6,
      children: items.map((items) => Text('Item ${items}')).toList(),
    );
  }

  getGridView2(){
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
      itemBuilder: (context, index) => Text(items.elementAt(index),),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Grid View'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                  child: getGridView2()
              ),
            ],
          )
      ),
    );
  }
}