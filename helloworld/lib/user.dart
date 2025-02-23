class User{
  late String _name;
  late int _age;

  User ({required String name, required int age}){
    this._name = name;
    this._age = age;
  }

  String get name => _name;
  int get age => _age;

  void run(){
    print("Hello World");
  }
}
