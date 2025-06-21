import 'package:classroom/blocs/user_bloc.dart';
import 'package:classroom/app_navigation_controller.dart';
import 'package:classroom/blocs/user_bloc.dart';
import 'package:classroom/configs/configs.dart';
import 'package:classroom/utils/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_navigation_controller.dart';
import '../configs/configs.dart';
import '../screens/onboarding/onboarding_page.dart';
import '../utils/snackbar.dart';

///Provider for user authentication
class AuthenticationBloc extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  ///Returns a boolean indicating whether an active user login exists
  Future<bool> checkSignIn(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool isLoggedIn = sp.getBool(Config.prefLoggedIn) ?? false;
    return Future.value(isLoggedIn);
  }

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    var bytes = utf8.encode(password.trim());
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future signInWithUsername(
      BuildContext context,
      UserBloc ub,
      String username,
      String password,
      ) async {
    setLoading(true);
    try {
      print('Attempting to sign in with username: $username');
      // Tra cứu username trong Firestore
      QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
          .collection(Config.fscUser)
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setLoading(false);
        showSnackBar(context, "Username not found.");
        return;
      }

      Map<String, dynamic> userData = query.docs.first.data();
      String storedPasswordHash = userData['passwordHash'];
      String inputPasswordHash = _hashPassword(password);

      if (storedPasswordHash != inputPasswordHash) {
        setLoading(false);
        showSnackBar(context, "Incorrect password.");
        return;
      }

      String uid = userData[Config.fsfUID];
      String name = userData[Config.fsfName];

      // Lưu thông tin người dùng vào SharedPreferences
      await ub.saveDataToSp(name, uid);

      setLoading(false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) {
          return const AppNavigationController();
        }),
            (route) => false,
      );
    } catch (e) {
      setLoading(false);
      showSnackBar(context, "An unexpected error occurred: $e");
    }
  }

  Future signUpWithUsername(
      BuildContext context,
      UserBloc ub,
      String username,
      String password,
      String name,
      ) async {
    setLoading(true);
    try {
      // Kiểm tra xem username đã tồn tại chưa
      QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
          .collection(Config.fscUser)
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setLoading(false);
        showSnackBar(context, "Username already exists. Please choose another.");
        return;
      }

      // Tạo UID mới (dùng timestamp và username để tạo UID đơn giản)
      String uid = "${username.trim()}_${DateTime.now().millisecondsSinceEpoch}";
      String passwordHash = _hashPassword(password);

      // Lưu thông tin người dùng vào Firestore
      await FirebaseFirestore.instance.collection(Config.fscUser).doc(uid).set({
        Config.fsfCreatedAt: DateTime.now(),
        Config.fsfName: name.trim(),
        Config.fsfUID: uid,
        'username': username.trim(),
        'passwordHash': passwordHash,
      });

      // Lưu thông tin vào SharedPreferences
      await ub.saveDataToSp(name, uid);

      setLoading(false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) {
          return const AppNavigationController();
        }),
            (route) => false,
      );
    } catch (e) {
      setLoading(false);
      showSnackBar(context, "An unexpected error occurred: $e");
    }
  }

  ///Fetch logged in user data from database
  Future fetchDataFromFirebase(
      String uid, UserBloc ub, BuildContext context) async {
    DocumentSnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .collection(Config.fscUser)
        .doc(uid)
        .get();

    Map<String, dynamic>? data = snap.data();
    if (data != null) {
      clearFields();
      await ub.saveDataToSp(data[Config.fsfName], data[Config.fsfUID]);

      setLoading(false);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) {
          return const AppNavigationController();
        }),
            (route) => false,
      );
    } else {
      setLoading(false);
    }
  }

  ///Clear fields
  void clearFields() {
    _isLoading = false;
  }

  ///Toggle loading status
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  ///Logout user
  Future logout(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear(); // Xóa toàn bộ dữ liệu trong SharedPreferences

    // Điều hướng về màn hình đăng nhập
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingPage()),
          (route) => false,
    );

    notifyListeners();
  }
}