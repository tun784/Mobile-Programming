import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
class CalculatorApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return CalculatorState();
  }
}

class CalculatorState extends State<StatefulWidget>{
  final TextEditingController editSoA = TextEditingController();
  final TextEditingController editSoB = TextEditingController();
  String ketqua = '';

  int? getNumber(number){
    String data = number.text;
    try{
      int num = int.parse(data);
      return num;
    }
    catch(e){
      print(data + ' khong phai la du lieu so');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(data + '  khong phai la du lieu so'),
            backgroundColor: Colors.red,
        )
      );
    }
    return null;
  }

  void cong(){
    int? soA = getNumber(editSoA);
    int? soB = getNumber(editSoB);
    if (soA == null || soB == null)
      return;

    setState(() {
      ketqua = (soA + soB).toString();
    });
  }
  void tru(){
    int? soA = getNumber(editSoA);
    int? soB = getNumber(editSoB);
    if (soA == null || soB == null)
      return;

    setState(() {
      ketqua = (soA - soB).toString();
    });
  }
  void nhan(){
    int? soA = getNumber(editSoA);
    int? soB = getNumber(editSoB);
    if (soA == null || soB == null)
      return;

    setState(() {
      ketqua = (soA * soB).toString();
    });
  }
  void chia(){
    int? soA = getNumber(editSoA);
    int? soB = getNumber(editSoB);
    if (soA == null || soB == null)
      return;

    setState(() {
      ketqua = (soA / soB).toString();
    });
  }


  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simplistic Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [

              Text(ketqua),
              Divider(),
              Text('Enter number A'),
              TextField(
                controller: editSoA,
              ),
              Text('Enter number B'),
              TextField(
                controller: editSoB,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: cong, child: Text('+')),
                  ElevatedButton(onPressed: tru, child: Text('-')),
                  ElevatedButton(onPressed: nhan, child: Text('x')),
                  ElevatedButton(onPressed: chia, child: Text(':')),
                ],
              ),
            ],
          )
        )
      )
    );
  }
}
