import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

class CustomRow extends StatelessWidget {
  final IconData icon;
  final String text;

  CustomRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black87,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 1.5.w, vertical: 0.9.h),
        child: Row(
          children: [
            FaIcon(icon,
                size: 12.sp,
                color: const Color(0xFF80CBC4)),
            SizedBox(
              width: 1.5.w,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: 12.sp,
                  color:
                  const Color(0xFF80CBC4)),
            ),
          ],
        ),
      ),
    );
  }
}
