import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
class DemoDialog extends StatelessWidget{
  showInfoDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Day la title'),
        content: Text('Day la content'),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text('OK')
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Demo Dialog'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              showInfoDialog(context);
            },
            child: const Text('Click me'),
          )
        )
      ),
    );
  }
}