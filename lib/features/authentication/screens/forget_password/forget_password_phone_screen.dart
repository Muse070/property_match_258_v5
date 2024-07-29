import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:sizer/sizer.dart';

import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../widgets/form_header_widget.dart';
import 'forget_password_otp/forget_password_otp.dart';

class ForgetPasswordPhoneScreen extends StatelessWidget {
  ForgetPasswordPhoneScreen({super.key});

  late final TextEditingController textController = TextEditingController();

  final _auth = Get.find<AuthenticationRepository>();

  late final TextEditingController phoneNumberContoller = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Reset with phone number",
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
              color: Colors.white,
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: 85.h,
          padding: EdgeInsets.only(top: 20.5.h, left: 2.5.w, right: 2.5.w, bottom: 1.5.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FormHeaderWidget(
                  icon: FontAwesomeIcons.mobile,
                  title: "Forgot Password?",
                  subTitle: "Submit your phone number in the field below.",
              ),
              SizedBox(height: 8.5.h,),
              InkWell( // Replace GestureDetector with InkWell
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: IntlPhoneField(
                  onChanged: (PhoneNumber phone) {
                    phoneNumberContoller.text = phone.completeNumber.toString();
                    // Update your controller/variable with the complete phone number here
                    print(phoneNumberContoller.text);
                  },
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  initialCountryCode: 'ZM',
                  onSubmitted: (_) {
                    try {
                      _auth.sendVerificationCode(phoneNumberContoller.text);
                      print("Phone number text is ${phoneNumberContoller.text}");
                    } catch (e) {
                      print("Error: $e");
                      Get.snackbar("Error", "$e");
                    }
                  },
                ),
              ),
              const Spacer(),
              ElevatedButton(
                  onPressed: () async {
                    String phoneNumber = phoneNumberContoller.text.trim();

                    if (phoneNumber.isEmpty) {
                      Get.snackbar('Error', 'Please enter your phone number.');
                      return; // Don't proceed if the phone number is empty
                    }

                    try {
                      _auth.isLoading.value = true; // Show loading indicator
                      await _auth.sendPasswordResetCode(phoneNumber);

                      // Assuming your sendPasswordResetCode returns a verification ID
                      String verificationId = _auth.verificationId.value;
                      if (verificationId.isNotEmpty) {
                        // Navigate to the OTP screen and pass the phone number
                        Get.to(() => OTPScreen(email: "",));
                      } else {
                        Get.snackbar('Error', 'Failed to send verification code. Please try again.');
                      }

                    } catch (e) {
                      // Handle errors (e.g., invalid phone number)
                      Get.snackbar('Error', 'An error occurred while sending the code.');
                      print('Error sending password reset code: $e'); // Log the error for debugging
                    } finally {
                      _auth.isLoading.value = false; // Hide loading indicator
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2.5,
                    shadowColor: const Color(0xff3B3C36),
                    minimumSize: const Size.fromHeight(60),
                  ),
                  child: Text(
                    "Next",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500
                    ),
                  )
              ),
              SizedBox(height: 10.h,)
            ],
          ),
        ),
      ),
    );
  }
}
