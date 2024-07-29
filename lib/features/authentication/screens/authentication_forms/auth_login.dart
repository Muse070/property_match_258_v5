import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/auth_sign_up.dart';
import 'package:property_match_258_v5/features/authentication/screens/forget_password/forget_password_mail_screen.dart';
import 'package:property_match_258_v5/features/authentication/screens/widgets/forget_password_model_bottom_sheet.dart';
import 'package:property_match_258_v5/repository/authentication_repository/authentication_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:sizer/sizer.dart';

import '../../../../model/user_models/user_model.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({super.key});

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _auth = Get.find<AuthenticationRepository>();
  final _userRepo = Get.find<UserRepository>();

  late Size mediaSize;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    ever(_userRepo.currentUser, (UserModel? user) {
      if (user != null) {
        if (kDebugMode) {
          print("${user.firstName} has successfully logged in :)");
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    return Container(
        decoration: const BoxDecoration(
            color: Colors.white70

          // gradient: LinearGradient(
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   colors: [Color(0xff34c0b3), Color(0xff0071b9)],
          // ),
        ),
        child: Scaffold(
          // backgroundColor: Colors.transparent,

            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                child: Column(
                  children: [
                    // const SizedBox(height: 60,),
                    _buildTop(),
                    _buildBottom(),
                  ],
                ),
              ),
            )
        )
    );
  }

  Widget _buildTop() {
    return Container(
      width: 100.w,
      height: 45.h,
      padding: EdgeInsets.symmetric(vertical: 5.5.h),
      decoration: const BoxDecoration(
        color: Colors.black87,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "img/258_white_no_bg.png",
            width: 200,
            height: 120,
            fit: BoxFit.cover,
          ),
          const Text(
            "Property Match",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 30
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 3.5.h),
      width: 100.w,
      child: ClipRect(
          child: Container(
            alignment: Alignment.center,
            child: _buildForm(),
          )
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // _buildGreyText("Email address"),
          SizedBox(height: 4.5.h,),
          TextFormField(
            controller: _emailController,
            cursorColor: Colors.black54,
            decoration: InputDecoration(
              hintText: "Email",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 12.sp),
              contentPadding: const EdgeInsets.all(10.9),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: const BorderSide(color: Colors.black54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: const BorderSide(color: Colors.green),
              ),
              suffixIcon: const Icon(Icons.email, color: Colors.grey),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your email";
              } else if (!value.contains("@")) {
                return "Please enter a valid email";
              }
              return null;
            },
            obscureText: false,
          ),
          const SizedBox(height: 40,),
          // _buildGreyText("Password"),
          TextFormField(
            controller: _passwordController,
            cursorColor: Colors.black87,
            decoration: InputDecoration(
              hintText: "Password",
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.all(10.9),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: const BorderSide(color: Colors.black54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: const BorderSide(color: Colors.green),
              ),
              suffixIcon: const Icon(Icons.password_rounded, color: Colors.grey),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your password";
              }
              return null;
            },
            obscureText: true,
          ),
          SizedBox(height: 1.5.h,),
          _buildRememberForgot(),
          SizedBox(height: 10.5.h,),
          _buildLoginButton(),
          SizedBox(height: 2.5.h,),
          // _buildGoogleLogin()
        ],
      ),
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
        text,
        style: const TextStyle(color: Colors.black87)
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
            onPressed: () {
              // ForgetPasswordScreen.buildShowModalBottomSheet(context);
              Get.to(() => ForgetPasswordMailScreen());
            },
            child: _buildGreyText("Forgot Password?")
        ),
        TextButton(
            onPressed: () {
              Get.to(() => const AuthSignUp());
            },
            style: ButtonStyle(
                surfaceTintColor: MaterialStateProperty.all(const Color(0xff3B3C36)),
                shadowColor: MaterialStateProperty.all(const Color(0xff3B3C36),
                )
            ),
            child: _buildGreyText("Sign Up")
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            try {
              setState(() {
                isLoading = true;
              });
              await _auth.loginWithEmailAndPassword(
                _emailController.text.trim(),
                _passwordController.text.trim(),
              );
              setState(() {
                isLoading = false;
              });
            } catch (error) {
              // Handle authentication error
              if (kDebugMode) {
                print("Authentication error: $error");
              }

              // If there's an error during login, do not navigate to MainPage
            }
          }
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.black87,
          // surfaceTintColor: Colors.black.withOpacity(0.8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.h),  // Change this value to adjust the radius
          ),
          shadowColor: const Color(0xFF80CBC4),
          minimumSize: Size.fromHeight(6.5.h),
        ),
        child: isLoading == true ? const CircularProgressIndicator(
          color: Colors.white,
        ) :
        const Text(
          "LOGIN",
          style: TextStyle(
              color: Colors.white
          ),
        )
    );
  }

  // Widget _buildGoogleLogin() {
  //   return Center(
  //     widthFactor: double.maxFinite,
  //     child: Column(
  //
  //       children: [
  //         _buildGreyText("Or Login With"),
  //         const SizedBox(height: 20,),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(
  //             // backgroundColor: Colors.transparent,
  //             side: const BorderSide(color: Colors.grey),
  //             minimumSize: Size.fromHeight(6.5.h),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(1.h),  // Change this value to adjust the radius
  //             ),
  //           ),
  //           child: SvgPicture.asset(
  //               "img/google.svg",
  //               width: 3.5.h,
  //               height: 3.5.h,
  //               fit: BoxFit.cover
  //           ),
  //           onPressed: () {
  //
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
}


