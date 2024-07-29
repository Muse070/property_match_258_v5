import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

class FormHeaderWidget extends StatelessWidget {
  const FormHeaderWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
  });

  final String title, subTitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(
          icon,
          size: 45.sp,
        ),
        Text(
          title,
          style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black87
          ),
        ),
        Text(
          subTitle,
          style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade700
          ),
        ),
      ],
    );
  }
}
