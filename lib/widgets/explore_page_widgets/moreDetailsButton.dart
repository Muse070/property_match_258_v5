import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

class MoreDetailsButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  const MoreDetailsButton({
    super.key, required this.onPressed, required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape:
          MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(1.3.h),
              // Change this value to adjust the border radius
              side: const BorderSide(
                color: Color(
                  0xFF005555,
                ),
              ), // Change this value to your desired border color
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Color(0xFF005555),
              ),
            ),
            SizedBox(
              width: 2.w,
            ),
            IconTheme(
              data: IconThemeData(
                  color: Color(0xFF005555), size: 12.sp),
              child: const FaIcon(FontAwesomeIcons.arrowRight),
            ),
          ],
        ));
  }
}
