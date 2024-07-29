import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/features/authentication/controllers/otp_controller.dart';
import 'package:property_match_258_v5/features/core/pages/welcome_page.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/otp_controller.dart';

class OTPScreen extends StatelessWidget {

  final String email; // Add email parameter

  const OTPScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    String otp;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "OTP verification",
          style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: IconTheme(
            data: IconThemeData(
              size: 12.sp,
              color: Colors.white70,
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Container(
        // height: 100.w,,
        padding: EdgeInsets.only(top: 20.5.h, left: 2.5.w, right: 2.5.w, bottom: 10.5.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Code",
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500
              ),
            ),
            Text("Verification",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500
              ),
            ),
            SizedBox(height: 3.h,),
            Text("Enter the verification code sent to you in the field below",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                )
            ),
            SizedBox(height: 5.h,),
            OtpTextField(
              borderColor: Colors.black,
              numberOfFields: 6,
              fillColor: const Color(0xFF80CBC4),
              filled: true,
              keyboardType: TextInputType.number,
              onSubmit: (code) {
                otp = code;
                OTPController.instance.verifyOTP(otp, email); // Pass email to controller
              },
            ),
            Spacer(),
            ElevatedButton(
                onPressed: () {
                  // if (OTPController.instance.isOTPVerified()) {
                  //   Get.offAll(const WelcomePage());
                  // }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  surfaceTintColor: Colors.black.withOpacity(0.9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2.5,
                  shadowColor: const Color(0xff3B3C36),
                  minimumSize:  const Size.fromHeight(60),
                  tapTargetSize: MaterialTapTargetSize.values.first,
                ),

                child: const Text(
                  "Next",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
