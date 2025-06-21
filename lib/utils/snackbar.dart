import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  // Kiểm tra xem widget có còn đang sống không
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(
          fontFamily: "Varela",
        ),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
