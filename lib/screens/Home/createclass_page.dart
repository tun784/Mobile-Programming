import 'dart:math';
import 'package:classroom/blocs/classroom_bloc.dart';
import 'package:classroom/blocs/user_bloc.dart';
import 'package:classroom/configs/configs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateClass extends StatefulWidget {
  const CreateClass({Key? key}) : super(key: key);

  @override
  _CreateClassState createState() => _CreateClassState();
}

class _CreateClassState extends State<CreateClass> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  bool _isLoading = false;

  // Hàm tạo mã lớp ngắn (6 ký tự, chữ và số)
  Future<String> _generateShortClassId() async {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    String classId;
    bool exists;

    do {
      classId = String.fromCharCodes(
        Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
      );
      // Kiểm tra xem mã đã tồn tại chưa
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(Config.fscClassroom)
          .doc(classId)
          .get();
      exists = doc.exists;
    } while (exists);

    return classId;
  }

  Future<void> _createClass() async {
    if (_nameController.text.trim().isEmpty || _subjectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final ClassroomBloc cb = Provider.of<ClassroomBloc>(context, listen: false);
      final UserBloc ub = Provider.of<UserBloc>(context, listen: false);

      String classId = await _generateShortClassId();
      await FirebaseFirestore.instance.collection(Config.fscClassroom).doc(classId).set({
        'id': classId,
        'name': _nameController.text.trim(),
        'subject': _subjectController.text.trim(),
        'teacherId': ub.uid,
        'teacherName': ub.name,
        'students': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Làm mới danh sách lớp học
      await cb.fetchClassrooms(context, ub.uid);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating class: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Class"),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Class Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: "Subject",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _createClass,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}