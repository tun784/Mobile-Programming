import 'package:classroom/blocs/classroom_bloc.dart';
import 'package:classroom/blocs/navigation_bloc.dart';
import 'package:classroom/blocs/user_bloc.dart';
import 'package:classroom/blocs/auth_bloc.dart';
import 'package:classroom/screens/Home/createclass_page.dart';
import 'package:classroom/screens/classroom/classroom_detail_page.dart';
import 'package:classroom/screens/onboarding/onboarding_page.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math';
final List<Color> cardColors = [
  Colors.blue.shade100,
  Colors.green.shade100,
  Colors.pink.shade100,
  Colors.orange.shade100,
  Colors.purple.shade100,
  Colors.teal.shade100,
  Colors.amber.shade100,
];
class AppNavigationController extends StatefulWidget {
  const AppNavigationController({super.key});

  @override
  State<AppNavigationController> createState() => _AppNavigationControllerState();
}

class _AppNavigationControllerState extends State<AppNavigationController>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation =
    CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    // Tải danh sách lớp học khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ClassroomBloc cb = Provider.of<ClassroomBloc>(context, listen: false);
      final UserBloc ub = Provider.of<UserBloc>(context, listen: false);
      cb.fetchClassrooms(context, ub.uid);
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Hiển thị dialog để nhập classId
  Future<void> _showJoinClassDialog(BuildContext context, ClassroomBloc cb, String studentId) async {
    TextEditingController classIdController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join a Class'),
          content: TextField(
            controller: classIdController,
            decoration: const InputDecoration(
              labelText: 'Enter Class ID',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Join'),
              onPressed: () async {
                if (classIdController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a Class ID")),
                  );
                  return;
                }
                await cb.joinClass(context, classIdController.text.trim(), studentId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    NavigationBloc nb = Provider.of<NavigationBloc>(context);
    ClassroomBloc cb = Provider.of<ClassroomBloc>(context);
    UserBloc ub = Provider.of<UserBloc>(context);
    AuthenticationBloc ab = Provider.of<AuthenticationBloc>(context);

    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
        title: const Text(
          "Classroom",
          style: TextStyle(
            fontFamily: "PublicSans",
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ab.logout(context); // Gọi hàm đăng xuất
            },
          ),
        ],
      ),
      floatingActionButton: !showFab
          ? const SizedBox()
          : FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: "Join Class",
            icon: Icons.join_inner,
            bubbleColor: Colors.white,
            iconColor: Colors.blue,
            titleStyle: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontFamily: "PublicSans",
              fontWeight: FontWeight.bold,
            ),
            onPress: () async {
              _animationController.reverse();
              await _showJoinClassDialog(context, cb, ub.uid);
            },
          ),
          Bubble(
            title: "Create Class",
            icon: Icons.create,
            bubbleColor: Colors.white,
            iconColor: Colors.blue,
            titleStyle: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontFamily: "PublicSans",
              fontWeight: FontWeight.bold,
            ),
            onPress: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateClass(),
                ),
              );
              _animationController.reverse();
            },
          ),
        ],
        animation: _animation,
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: Colors.blue,
        iconData: FontAwesomeIcons.circlePlus,
        backGroundColor: Colors.white,
      ),
      body: SizedBox(
        width: size.width,
        child: getBody(nb.bottomNavIndex, cb),
      ),
    );
  }

  Widget getBody(int index, ClassroomBloc cb) {
    switch (index) {
      case 0:
        return cb.classrooms.isEmpty
            ? const Center(child: Text("No classrooms available"))
            : ListView.builder(
          itemCount: cb.classrooms.length,
          itemBuilder: (context, i) {
            // Pick a color based on index for consistency
            final color = cardColors[i % cardColors.length];
            final classroom = cb.classrooms[i];
            return Card(
              color: color, // Set the card color here
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassroomDetailPage(classroomId: classroom.id),
                    ),
                  );
                },
                title: Text(
                  classroom.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(classroom.subject),
                    Text(
                      "Class ID: ${classroom.id}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Text(
                  "Teacher: ${classroom.teacherName}",
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            );
          },
        );
      default:
        return const Center(child: Text("Coming soon"));
    }
  }

  Widget getBottomNavBarIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        icon,
      ),
    );
  }
}