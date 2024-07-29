import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import '../forget_password/forget_password_mail_screen.dart';
import '../forget_password/forget_password_phone_screen.dart';
import 'forget_password_button_widget.dart';

class ForgetPasswordScreen {

  static Future<dynamic> buildShowModalBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only( // Apply border radius only to top corners
          topLeft: Radius.circular(2.5.h),
          topRight: Radius.circular(2.5.h),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h), // Adjusted padding
        height: 45.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose Your Reset Method",
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600
              ),),
            Text(
              "Please select a method to reset your password.",
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600]
              ),
            ),
            const SizedBox(height: 30,),
            ForgetPasswordBtnWidget(
              title: "Reset via Email",
              subTitle: "A reset link will be sent to your email",
              btnIcon: FontAwesomeIcons.envelope,
              onTap: () {
                Get.to(() => ForgetPasswordMailScreen());
              },
            ),
            const SizedBox(height: 30,),
            ForgetPasswordBtnWidget(
              title: "Reset via Phone",
              subTitle: "A verification code will be sent to your phone",
              btnIcon: FontAwesomeIcons.phone,
              onTap: () {
                Get.to(() => ForgetPasswordPhoneScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}