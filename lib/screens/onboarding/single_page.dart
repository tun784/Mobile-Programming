import 'package:classroom/blocs/auth_bloc.dart';
import 'package:classroom/blocs/user_bloc.dart';
import 'package:classroom/utils/snackbar.dart';
import 'package:flutter/material.dart';

///Unified class for single page of onboarding PageView
class SinglePage extends StatefulWidget {
  final String imagePath, title, subtitle;
  final Widget nextButton;
  final PageController pageController;
  final AuthenticationBloc ab;
  final UserBloc ub;

  const SinglePage({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.nextButton,
    required this.pageController,
    required this.ab,
    required this.ub,
  }) : super(key: key);

  @override
  _SinglePageState createState() => _SinglePageState();
}

class _SinglePageState extends State<SinglePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isSignUp = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      mainAxisSize: MainAxisSize.max, // Sử dụng hết chiều cao của màn hình
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded( // Cho phép hình ảnh và nội dung mở rộng
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: size.width,
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 30),
                getTextContent(size),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (isSignUp)
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: "Username",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: widget.ab.isLoading
                            ? null
                            : () {
                          if (usernameController.text.trim().isEmpty ||
                              passwordController.text.trim().isEmpty ||
                              (isSignUp && nameController.text.trim().isEmpty)) {
                            showSnackBar(context, "Please fill in all fields");
                            return;
                          }
                          if (widget.ab.isLoading) {
                            showSnackBar(context, "Please wait. Operation in progress");
                            return;
                          }
                          if (isSignUp) {
                            widget.ab.signUpWithUsername(
                              context,
                              widget.ub,
                              usernameController.text,
                              passwordController.text,
                              nameController.text,
                            );
                          } else {
                            widget.ab.signInWithUsername(
                              context,
                              widget.ub,
                              usernameController.text,
                              passwordController.text,
                            );
                          }
                        },
                        child: widget.ab.isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : Text(
                          isSignUp ? "Sign Up with Username" : "Sign In with Username",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isSignUp = !isSignUp;
                          });
                        },
                        child: Text(
                          isSignUp
                              ? "Already have an account? Sign In"
                              : "Don't have an account? Sign Up",
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getTextContent(Size size) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width,
            child: Row(
              children: [
                SizedBox(
                  width: size.width * 0.7,
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 27,
                      letterSpacing: 1.3,
                      fontFamily: "PublicSans",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                widget.nextButton,
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: size.width / 1.4,
            child: Text(
              widget.subtitle,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: "PublicSans",
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}