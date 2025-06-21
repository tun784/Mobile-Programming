import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AssignmentDetailPage extends StatefulWidget {
  final String classroomId;
  final Map<String, dynamic> assignment;

  const AssignmentDetailPage({
    Key? key,
    required this.classroomId,
    required this.assignment,
  }) : super(key: key);

  @override
  _AssignmentDetailPageState createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  String? _submittedFileUrl;
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Hỗ trợ tất cả loại file, bao gồm hình ảnh
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      print("Selected file: ${file.path}, type: ${result.files.single.extension}"); // Debug log
      String fileName = "submissions/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}";
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
          _submittedFileUrl = downloadUrl;
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

  Future<void> _submitAssignment() async {
    if (_submittedFileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please attach a file to submit")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String submissionId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('classroom')
          .doc(widget.classroomId)
          .collection('files')
          .doc(widget.assignment['id'])
          .collection('submissions')
          .doc(submissionId)
          .set({
        'id': submissionId,
        'fileUrl': _submittedFileUrl,
        'submittedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Assignment submitted successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting assignment: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? deadline = widget.assignment['deadline'] != null
        ? (widget.assignment['deadline'] as Timestamp).toDate()
        : null;
    DateTime now = DateTime.now();
    bool isPastDeadline = deadline != null && now.isAfter(deadline);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment['name']),
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
              Text(
                "Type: ${widget.assignment['type']}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                "Description: ${widget.assignment['description'] ?? 'No description'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                "Attached File: ${widget.assignment['attachedFile'] != null ? 'View file' : 'No file attached'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                "Deadline: ${deadline != null ? deadline.toString().substring(0, 16) : 'No deadline'}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                "Submit Your Work",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _submittedFileUrl != null ? "File attached" : "No file attached",
                      style: TextStyle(color: _submittedFileUrl != null ? Colors.black : Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isPastDeadline ? null : _pickFile,
                    child: const Text("Attach File"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPastDeadline ? Colors.grey : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isPastDeadline || _isSubmitting
                    ? null
                    : _submitAssignment,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPastDeadline || _isSubmitting ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}