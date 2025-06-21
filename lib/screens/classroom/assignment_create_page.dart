import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AssignmentCreatePage extends StatefulWidget {
  final String classroomId;

  const AssignmentCreatePage({Key? key, required this.classroomId}) : super(key: key);

  @override
  _AssignmentCreatePageState createState() => _AssignmentCreatePageState();
}

class _AssignmentCreatePageState extends State<AssignmentCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _attachedFileUrl;
  DateTime? _deadline;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Hỗ trợ tất cả loại file, bao gồm hình ảnh
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      print("Selected file: ${file.path}, type: ${result.files.single.extension}"); // Debug log
      String fileName = "assignments/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}";
      try {
        // Ensure Firebase user is authenticated
        if (FirebaseAuth.instance.currentUser == null) {
          await FirebaseAuth.instance.signInAnonymously();
        }
        UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print("Upload successful, URL: $downloadUrl"); // Debug log
        setState(() {
          _attachedFileUrl = downloadUrl;
        });
      } catch (e, stack) {
        print("Upload error: $e\n$stack");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading file: $e")),
        );
      }
    } else {
      print("No file selected"); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );
    }
  }

  Future<void> _pickDeadline() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _deadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Assignment"),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _attachedFileUrl != null ? "File attached" : "No file attached",
                      style: TextStyle(color: _attachedFileUrl != null ? Colors.black : Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text("Attach File"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline != null ? _deadline.toString() : "No deadline set",
                      style: TextStyle(color: _deadline != null ? Colors.black : Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDeadline,
                    child: const Text("Set Deadline"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter a title")),
                    );
                    return;
                  }
                  String assignmentId = const Uuid().v4();
                  await FirebaseFirestore.instance
                      .collection('classroom')
                      .doc(widget.classroomId)
                      .collection('files')
                      .doc(assignmentId)
                      .set({
                    'id': assignmentId,
                    'name': _titleController.text.trim(),
                    'type': 'Assignment',
                    'description': _descriptionController.text.trim(),
                    'attachedFile': _attachedFileUrl,
                    'deadline': _deadline != null ? Timestamp.fromDate(_deadline!) : null,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                },
                child: const Text("Create Assignment"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}