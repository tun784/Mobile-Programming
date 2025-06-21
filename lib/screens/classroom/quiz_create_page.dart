import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class QuizCreatePage extends StatefulWidget {
  final String classroomId;

  const QuizCreatePage({Key? key, required this.classroomId}) : super(key: key);

  @override
  _QuizCreatePageState createState() => _QuizCreatePageState();
}

class _QuizCreatePageState extends State<QuizCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  bool _isSubmitting = false; // Biến kiểm soát trạng thái submit

  void _addQuestion() {
    setState(() {
      _questions.add({
        'question': '',
        'answers': ['', '', '', ''],
        'correctAnswerIndex': 0,
      });
    });
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return; // Ngăn chặn submit nhiều lần

    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _durationController.text.trim().isEmpty ||
        _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields and add at least one question")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String quizId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('classroom')
          .doc(widget.classroomId)
          .collection('quizzes')
          .doc(quizId)
          .set({
        'id': quizId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'duration': int.parse(_durationController.text.trim()),
        'questions': _questions,
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Thoát ngay sau khi tạo thành công
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating quiz: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Quiz"),
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
                  labelText: "Quiz Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: "Duration (minutes)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                "Questions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Question ${index + 1}",
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              _questions[index]['question'] = value;
                            },
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(
                            4,
                                (answerIndex) => TextField(
                              decoration: InputDecoration(
                                labelText: "Answer ${answerIndex + 1}",
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                _questions[index]['answers'][answerIndex] = value;
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: _questions[index]['correctAnswerIndex'],
                            onChanged: (newValue) {
                              setState(() {
                                _questions[index]['correctAnswerIndex'] = newValue!;
                              });
                            },
                            items: List.generate(4, (i) => i)
                                .map((value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text("Correct Answer: Answer ${value + 1}"),
                            ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text("Add Question"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuiz,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create Quiz"),
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
    _durationController.dispose();
    super.dispose();
  }
}