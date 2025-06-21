import 'package:classroom/configs/configs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///Provider for user data
class UserBloc extends ChangeNotifier {
  String _name = "";
  String _uid = "";

  String get name => _name;
  String get uid => _uid;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setUid(String value) {
    _uid = value;
    notifyListeners();
  }

  Future saveDataToSp(String name, String uid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    await sp.setString(Config.prefName, name);
    await sp.setString(Config.prefUid, uid);
    await sp.setBool(Config.prefLoggedIn, true);

    _name = name;
    _uid = uid;

    notifyListeners();
  }

  Future fetchDataFromSp() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    _name = sp.getString(Config.prefName) ?? "";
    _uid = sp.getString(Config.prefUid) ?? "";

    notifyListeners();
  }
}