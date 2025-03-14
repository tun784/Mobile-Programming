import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class DemoListView extends StatelessWidget{
  static int countItems = 200;
  List<String> items = List.generate(countItems, (index) => "Item ${index + 1}");
  getListView(){
    return ListView(
      children: items.map((items) => Text(items)).toList(),
    );
  }

  getListView2(){
    return ListView.builder(
      itemCount: countItems,
      itemBuilder: (context, index) => Text(items.elementAt(index)),
      // itemBuilder: (context, index){
      //   return Text(items.elementAt(index));
      // },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demo List View'),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: getListView2(),
              ),
            ],
          ),
        )
      ),
    );
  }

}