import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TestStatefulWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return TestState();
  }
}
class TestState extends State<StatefulWidget>{
    int _counter = 0;
    void increaseCounter(){
      setState((){
        _counter++;
      });
      print('${_counter}');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: increaseCounter,
                    child: Text(_counter.toString()))
              ],
            ))
      )
    );
  }
}