import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../authentication_forms/auth_login.dart';
import '../widgets/form_header_widget.dart';

class ForgetPasswordMailScreen extends StatelessWidget {
  ForgetPasswordMailScreen({super.key});

  final TextEditingController textController = TextEditingController();
  final _auth = Get.find<AuthenticationRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Reset with email",
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
                color: Colors.white
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
          height: 100.h,
          padding: EdgeInsets.only(top: 20.5.h, left: 2.5.w, right: 2.5.w, bottom: 10.5.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FormHeaderWidget(
                  icon: FontAwesomeIcons.envelope,
                  title: "Forgot Password?",
                  subTitle: "Submit your email in the field below."
              ),
              SizedBox(height: 8.5.h,),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: TextField(
                  controller: textController,
                  decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onSubmitted: (email) {
                    String email = textController.text.trim();
                    if (email.isEmpty) {
                      Get.snackbar('Error', 'Please enter your email address.');
                      return;
                    }

                    // Send password reset email
                    try {
                      _auth.isLoading.value = true; // Show loading state
                      _auth.sendPasswordResetEmail(email);
                      // (Optional) Navigate back or show a confirmation message
                      Get.to(const AuthLogin());
                    }
                    catch (e) {
                      // (Optional) Handle other errors
                    }
                    finally {
                      _auth.isLoading.value = false; // Hide loading state
                    }
                  },
                ),
              ),
              SizedBox(height: 2.5.h,),
              SizedBox(
                width: 50.w,
                child: ElevatedButton(
                  onPressed: () async {
                    String email = textController.text.trim();
                    if (email.isEmpty) {
                      Get.snackbar('Error', 'Please enter your email address.');
                      return;
                    }

                    // Send password reset email
                    try {
                      _auth.resendPasswordResetEmail(textController.text);

                      // (Optional) Navigate back or show a confirmation message
                      Get.back();
                    } catch (e) {
                      // (Optional) Handle other errors
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,  // White background
                    foregroundColor: Colors.black,  // Black text
                    textStyle: TextStyle(
                        color: Colors.black87
                    ),
                    side: BorderSide(color: Colors.black), // Black border
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0.0, // Optional: Add elevation for a subtle shadow effect
                    shadowColor: Colors.grey, // Optional: Customize the shadow color
                    minimumSize: const Size.fromHeight(40), // Set your desired height
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Optional: Adjust tap target size
                  ),
                  child: Obx(() => _auth.isLoading.value // Display loading indicator or text
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Resend Email", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))
                  ),
                ),
              ),

              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  String email = textController.text.trim();
                  if (email.isEmpty) {
                    Get.snackbar('Error', 'Please enter your email address.');
                    return;
                  }

                  // Send password reset email
                  try {
                    final AuthenticationRepository authRepository = Get.find<AuthenticationRepository>();
                    await authRepository.sendPasswordResetEmail(email);

                    // (Optional) Navigate back or show a confirmation message
                    Get.back();
                  } catch (e) {
                    // (Optional) Handle other errors
                  }
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
                child: Obx(() => _auth.isLoading.value // Display loading indicator or text
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Next", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
                ),
              ),
              SizedBox(height: 10.h,)

              // const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
