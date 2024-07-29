import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppLargeText extends StatelessWidget {
  double size;
  final String text;
  final Color color;
   AppLargeText({super.key,
     this.size=25,
     required this.text,
     this.color=Colors.white});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(
        color: Colors.black,
        fontSize: size,
        fontWeight: FontWeight.bold,
      )
    );
  }
}
