import 'package:classroom/configs/configs.dart';
import 'package:classroom/models/classroom_model.dart';
import 'package:classroom/utils/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

///Provider for classroom joining and creation
class ClassroomBloc extends ChangeNotifier {
  ClassroomModel _classroomModel = ClassroomModel(
    id: "",
    name: "",
    subject: "",
    teacherId: "",
    teacherName: "",
    createdAt: DateTime.now(),
    students: [],
  );

  List<ClassroomModel> _classrooms = []; // Danh sách lớp học
  List<ClassroomModel> get classrooms => _classrooms;

  ClassroomModel get classroom => _classroomModel;

  Future createClass(
      BuildContext context,
      String name,
      String subject,
      String teacherId,
      String teacherName,
      ) async {
    String classId = const Uuid().v4();

    await FirebaseFirestore.instance
        .collection(Config.fscClassroom)
        .doc(classId)
        .set({
      "id": classId,
      "name": name,
      "subject": subject,
      "teacherId": teacherId,
      "teacherName": teacherName,
      "createdAt": FieldValue.serverTimestamp(), // Sử dụng serverTimestamp
      "students": [],
    }).then((value) {
      _classroomModel = ClassroomModel(
        id: classId,
        name: name,
        subject: subject,
        teacherId: teacherId,
        teacherName: teacherName,
        createdAt: DateTime.now(),
        students: [],
      );
      showSnackBar(context, "Classroom created successfully");
      fetchClassrooms(context, teacherId); // Tải lại danh sách sau khi tạo
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      showSnackBar(context, error.toString());
    });
  }

  Future joinClass(
      BuildContext context,
      String classId,
      String studentId,
      ) async {
    DocumentSnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .collection(Config.fscClassroom)
        .doc(classId)
        .get();

    Map<String, dynamic>? data = snap.data();

    if (data != null) {
      List students = data["students"];
      if (students.contains(studentId)) {
        showSnackBar(context, "Already joined this class");
      } else {
        students.add(studentId);
        await FirebaseFirestore.instance
            .collection(Config.fscClassroom)
            .doc(classId)
            .update({
          "students": students,
        }).then((value) {
          showSnackBar(context, "Successfully joined class");
          fetchClassrooms(context, studentId); // Tải lại danh sách sau khi tham gia
        }).onError((error, stackTrace) {
          showSnackBar(context, error.toString());
        });
      }
    } else {
      showSnackBar(context, "No such class exists");
    }
  }

  Future fetchClassrooms(BuildContext context, String userId) async {
    try {
      // Lấy các lớp mà người dùng là giáo viên hoặc học sinh
      QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
          .collection(Config.fscClassroom)
          .where('teacherId', isEqualTo: userId)
          .get();

      QuerySnapshot<Map<String, dynamic>> queryStudents = await FirebaseFirestore.instance
          .collection(Config.fscClassroom)
          .where('students', arrayContains: userId)
          .get();

      List<ClassroomModel> tempClassrooms = [];

      // Lấy các lớp do người dùng tạo
      for (var doc in query.docs) {
        Map<String, dynamic> data = doc.data();
        // Đảm bảo dữ liệu hợp lệ trước khi ánh xạ
        if (data['createdAt'] != null) {
          tempClassrooms.add(ClassroomModel.fromJson(data));
        }
      }

      // Lấy các lớp mà người dùng tham gia
      for (var doc in queryStudents.docs) {
        Map<String, dynamic> data = doc.data();
        // Đảm bảo dữ liệu hợp lệ trước khi ánh xạ
        if (data['createdAt'] != null) {
          tempClassrooms.add(ClassroomModel.fromJson(data));
        }
      }

      _classrooms = tempClassrooms.toSet().toList(); // Loại bỏ trùng lặp
      notifyListeners();
    } catch (e) {
      showSnackBar(context, "Error fetching classrooms: $e");
    }
  }
}