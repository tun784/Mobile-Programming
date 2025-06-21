import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:classroom/blocs/user_bloc.dart';

class QuizTakePage extends StatefulWidget {
  final String classroomId;
  final Map<String, dynamic> quiz;

  const QuizTakePage({
    Key? key,
    required this.classroomId,
    required this.quiz,
  }) : super(key: key);

  @override
  _QuizTakePageState createState() => _QuizTakePageState();
}

class _QuizTakePageState extends State<QuizTakePage> {
  late Timer _timer;
  late int _remainingSeconds;
  List<int?> _selectedAnswers = [];
  bool _hasStarted = false;
  bool _isSubmitting = false;
  bool _hasSubmitted = false; // Kiểm tra xem đã nộp bài chưa

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
    _remainingSeconds = widget.quiz['duration'] * 60; // Chuyển phút sang giây
    _selectedAnswers = List.filled(widget.quiz['questions'].length, null);
  }

  Future<void> _checkSubmissionStatus() async {
    final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
    final QuerySnapshot<Map<String, dynamic>> submissions = await FirebaseFirestore.instance
        .collection('classroom')
        .doc(widget.classroomId)
        .collection('quizzes')
        .doc(widget.quiz['id'])
        .collection('submissions')
        .where('id', isEqualTo: ub.uid) // Giả định userId là id của sinh viên
        .get();

    if (submissions.docs.isNotEmpty) {
      setState(() {
        _hasSubmitted = true;
      });
    }
  }

  void _startQuiz() {
    if (_hasSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already submitted this quiz.")),
      );
      return;
    }
    setState(() {
      _hasStarted = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        _submitQuiz(autoSubmit: true);
      }
    });
  }

  Future<void> _submitQuiz({bool autoSubmit = false}) async {
    if (_isSubmitting || _hasSubmitted) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      _timer.cancel();
      int correctAnswers = 0;
      for (int i = 0; i < widget.quiz['questions'].length; i++) {
        if (_selectedAnswers[i] == widget.quiz['questions'][i]['correctAnswerIndex']) {
          correctAnswers++;
        }
      }

      int totalQuestions = widget.quiz['questions'].length;
      double scorePercentage = (correctAnswers / totalQuestions) * 100;
      int score = scorePercentage.round();

      final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
      String submissionId = const Uuid().v4();
      await FirebaseFirestore.instance
          .collection('classroom')
          .doc(widget.classroomId)
          .collection('quizzes')
          .doc(widget.quiz['id'])
          .collection('submissions')
          .doc(submissionId)
          .set({
        'id': ub.uid, // Sử dụng userId làm id của submission
        'answers': _selectedAnswers,
        'score': score,
        'totalQuestions': totalQuestions,
        'submittedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _hasSubmitted = true;
      });

      // Hiển thị dialog kết quả
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Quiz Result"),
          content: Text("Your score: $score/100"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                Navigator.pop(context); // Quay lại trang trước
              },
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting quiz: $e")),
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
        title: Text(widget.quiz['title']),
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
        child: _hasSubmitted
            ? const Center(child: Text("You have already completed this quiz."))
            : (_hasStarted ? _buildQuiz() : _buildStartScreen()),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.quiz['title'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(widget.quiz['description']),
          const SizedBox(height: 16),
          Text("Duration: ${widget.quiz['duration']} minutes"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _startQuiz,
            child: const Text("Start Quiz"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Time Remaining: ${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: widget.quiz['questions'].length,
            itemBuilder: (context, index) {
              final question = widget.quiz['questions'][index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${index + 1}: ${question['question']}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        4,
                            (answerIndex) => RadioListTile<int>(
                          title: Text(question['answers'][answerIndex]),
                          value: answerIndex,
                          groupValue: _selectedAnswers[index],
                          onChanged: (value) {
                            setState(() {
                              _selectedAnswers[index] = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : () => _submitQuiz(),
          child: _isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Submit Quiz"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}