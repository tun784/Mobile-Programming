import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class DemoScaffold extends StatelessWidget{
  clickIconPhone(){}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Center(child: Text('Title')),
        actions: [
          IconButton(onPressed: clickIconPhone, icon: Icon(Icons.phone)),
          IconButton(onPressed: (){},icon:Icon(Icons.alarm)),
          IconButton(onPressed: (){},icon:Icon(Icons.inbox)),
        ],
        leading: Builder(builder: (context) => IconButton(onPressed: () {Scaffold.of(context).openDrawer();}, icon: Icon(Icons.menu))),
      ),
      body:
        SafeArea(
          child: Container(
            alignment: Alignment.topLeft,
            color: Colors.orange,
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 30,
            ),
            child: Text('Container'),
          )

          // child: Column(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     Expanded(
          //         child:
          //           Container(
          //             width: 30,
          //             color: Colors.green,
          //           ),
          //           flex: 10,
          //     ),
          //     Expanded(
          //         child:
          //           Container(
          //             width: 30,
          //             color: Colors.red,
          //           ),
          //       flex: 4,
          //     ),
          //     Expanded(
          //       child:
          //         Container(
          //           width: 30,
          //           color: Colors.cyan,
          //         ),
          //       flex: 2,
          //     )
          //   ],
          // ),

          // child: Stack(
          //   children: [
          //     Container(
          //       width: 200,
          //       height: 200,
          //       color: Colors.cyan,
          //     ),
          //     Container(
          //       width: 100,
          //       height: 100,
          //       color: Colors.red,
          //     )
          //   ],
          // )
        ),
      drawer: Drawer(
        child: SafeArea(child: Text('This is a drawer')),
      ),
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.square),
          label: 'Multi-task',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.arrow_back),
          label: 'Back',
        )
      ]),
      floatingActionButton: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          // shape: BoxShape.circle
        ),
        child: ElevatedButton(
          onPressed: (){}, child: Icon(Icons.plus_one),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(0),
          ),
        ),
      ),
    );
  }
}