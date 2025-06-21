import 'package:classroom/blocs/classroom_bloc.dart';
import 'package:classroom/blocs/user_bloc.dart';
import 'package:classroom/configs/configs.dart';
import 'package:classroom/models/classroom_model.dart';
import 'package:classroom/screens/classroom/assignment_create_page.dart';
import 'package:classroom/screens/classroom/assignment_detail_page.dart';
import 'package:classroom/screens/classroom/assignment_edit_page.dart';
import 'package:classroom/screens/classroom/quiz_create_page.dart';
import 'package:classroom/screens/classroom/quiz_take_page.dart';
import 'package:classroom/utils/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ClassroomDetailPage extends StatefulWidget {
  final String classroomId; // Thay classroom bằng classroomId

  const ClassroomDetailPage({Key? key, required this.classroomId}) : super(key: key);

  @override
  _ClassroomDetailPageState createState() => _ClassroomDetailPageState();
}

class _ClassroomDetailPageState extends State<ClassroomDetailPage> {
  List<Map<String, dynamic>> _files = [];
  bool _isLoading = false;
  ClassroomModel? _classroom; // Lưu thông tin classroom sau khi lấy từ Firestore

  @override
  void initState() {
    super.initState();
    _fetchClassroomDetails();
    _fetchFiles();
  }
  List<String> _studentNames = [];
  // Lấy thông tin lớp học từ Firestore
  Future<void> _fetchClassroomDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
          .collection(Config.fscClassroom)
          .doc(widget.classroomId)
          .get();

      if (doc.exists) {
        final classroom = ClassroomModel.fromJson(doc.data()!);
        List<String> uids = List<String>.from(classroom.students);
        List<String> names = [];
        for (String uid in uids) {
          var userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if (userDoc.exists) {
            names.add(userDoc.data()?['name'] ?? uid);
          } else {
            names.add(uid);
          }
        }
        setState(() {
          _classroom = classroom;
          _studentNames = names;
        });
      } else {
        showSnackBar(context, "Classroom not found");
        Navigator.pop(context);
      }
    } catch (e) {
      showSnackBar(context, "Error fetching classroom details: $e");
      Navigator.pop(context);
    }
  }

  // Lấy danh sách file từ Firestore
  Future<void> _fetchFiles() async {
    setState(() {
      _isLoading = true;
    });
    try {
      QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore.instance
          .collection(Config.fscClassroom)
          .doc(widget.classroomId)
          .collection('files')
          .get();

      setState(() {
        _files = query.docs.map((doc) => doc.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showSnackBar(context, "Error fetching files: $e");
    }
  }

  // Tạo file mới
  Future<void> _createFile() async {
    TextEditingController fileNameController = TextEditingController();
    String fileType = 'Document';

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fileNameController,
                decoration: const InputDecoration(
                  labelText: 'File Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: fileType,
                onChanged: (String? newValue) {
                  setState(() {
                    fileType = newValue!;
                  });
                },
                items: <String>['Document', 'Assignment']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                if (fileNameController.text.trim().isEmpty) {
                  showSnackBar(context, "Please enter a file name");
                  return;
                }
                String fileId = const Uuid().v4();
                await FirebaseFirestore.instance
                    .collection(Config.fscClassroom)
                    .doc(widget.classroomId)
                    .collection('files')
                    .doc(fileId)
                    .set({
                  'id': fileId,
                  'name': fileNameController.text.trim(),
                  'type': fileType,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.of(context).pop();
                _fetchFiles();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserBloc ub = Provider.of<UserBloc>(context);
    if (_classroom == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isTeacher = _classroom!.teacherId == ub.uid;
    final DateTime now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(_classroom!.name),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header lớp học
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.class_, size: 32, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _classroom!.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_classroom!.subject, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Teacher: ${_classroom!.teacherName}"),
                  const SizedBox(height: 8),
                  Text("Class ID: ${_classroom!.id}", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            // Danh sách học sinh
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Students",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _classroom!.students.isEmpty
                      ? const Text("No students yet")
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _studentNames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_studentNames[index]),
                      );
                    },
                  )
                ],
              ),
            ),
            // Danh sách file
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Files",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _createFile,
                        icon: const Icon(Icons.add),
                        label: const Text("Create File"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _files.isEmpty
                      ? const Text("No files yet")
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _files.length,
                    itemBuilder: (context, index) {
                      final file = _files[index];
                      DateTime? deadline = file['deadline'] != null
                          ? (file['deadline'] as Timestamp).toDate()
                          : null;
                      bool isPastDeadline = deadline != null && now.isAfter(deadline);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          onTap: () {
                            if (isTeacher) {
                              // Giáo viên: Hiển thị dialog với nút chỉnh sửa
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(file['name']),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Type: ${file['type']}"),
                                        const SizedBox(height: 8),
                                        Text("Description: ${file['description'] ?? 'No description'}"),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Attached File: ${file['attachedFile'] != null ? 'View file' : 'No file attached'}",
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Deadline: ${deadline != null ? deadline.toString().substring(0, 16) : 'No deadline'}",
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    if (file['type'] == 'Assignment')
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AssignmentEditPage(
                                                classroomId: widget.classroomId,
                                                assignment: file,
                                              ),
                                            ),
                                          ).then((_) => _fetchFiles());
                                        },
                                        child: const Text("Edit"),
                                      ),
                                    TextButton(
                                      child: const Text("Close"),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Sinh viên: Điều hướng đến trang chi tiết bài tập
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AssignmentDetailPage(
                                    classroomId: widget.classroomId,
                                    assignment: file,
                                  ),
                                ),
                              );
                            }
                          },
                          leading: Icon(
                            file['type'] == 'Assignment'
                                ? Icons.assignment
                                : Icons.description,
                          ),
                          title: Text(file['name']),
                          subtitle: Text(file['type']),
                          trailing: file['createdAt'] != null
                              ? Text(
                            (file['createdAt'] as Timestamp)
                                .toDate()
                                .toString()
                                .substring(0, 16),
                          )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Danh sách bài trắc nghiệm
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quizzes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('classroom')
                        .doc(widget.classroomId)
                        .collection('quizzes')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        print("StreamBuilder error: ${snapshot.error}");
                        return const Center(child: Text("Error loading quizzes."));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text("No quizzes available.");
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final quiz = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                          quiz['id'] = snapshot.data!.docs[index].id; // Thêm ID của document
                          return FutureBuilder<int?>(
                            future: _getStudentScore(quiz['id']),
                            builder: (context, scoreSnapshot) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  title: Text(quiz['title'] ?? 'No Title'),
                                  subtitle: Text(quiz['description'] ?? 'No Description'),
                                  trailing: !isTeacher
                                      ? (scoreSnapshot.data != null
                                      ? Text(
                                    "Score: ${scoreSnapshot.data}/100",
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                  )
                                      : ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => QuizTakePage(
                                            classroomId: widget.classroomId,
                                            quiz: quiz,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("Take Quiz"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ))
                                      : null,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            // Section cho giáo viên
            if (isTeacher)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Teacher Actions",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssignmentCreatePage(classroomId: widget.classroomId),
                              ),
                            ).then((_) => _fetchFiles());
                          },
                          child: const Text("Giao bài tập"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizCreatePage(classroomId: widget.classroomId),
                              ),
                            ).then((_) => _fetchFiles());
                          },
                          child: const Text("Giao bài trắc nghiệm"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<int?> _getStudentScore(String quizId) async {
    final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
    final QuerySnapshot<Map<String, dynamic>> submissions = await FirebaseFirestore.instance
        .collection('classroom')
        .doc(widget.classroomId)
        .collection('quizzes')
        .doc(quizId)
        .collection('submissions')
        .where('id', isEqualTo: ub.uid) // Giả định userId là id của sinh viên
        .get();

    if (submissions.docs.isNotEmpty) {
      return submissions.docs.first['score'] as int?;
    }
    return null;
  }
}