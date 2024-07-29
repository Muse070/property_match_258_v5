
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:sizer/sizer.dart';

import 'agent_signup_forms/agent_signup.dart';
import 'client_signup_forms/client_signup.dart';

class AuthSignUp extends StatefulWidget {
  const AuthSignUp({super.key});

  @override
  State<AuthSignUp> createState() => _AuthSignUpState();
}

class _AuthSignUpState extends State<AuthSignUp> with TickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Sign Up Options",
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
        padding: EdgeInsets.only(top: 8.5.h ,left: 2.5.w, right: 2.5.w, bottom: 15.5.h),
        color: Colors.grey.shade200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   "Select your sign up option",
            //   style: TextStyle(
            //     fontSize: 14.sp,
            //     fontWeight: FontWeight.w400
            //   ),
            // ),
            SizedBox(height: 3.h,),
            userTypeCard(
                    () {
                  Get.to(() => const AgentSignup());
                },
                FontAwesomeIcons.briefcase,
                "Join as an agent",
                "Represent your agency and connect with clients"
            ),
            SizedBox(height: 7.h,),
            userTypeCard(
                    () {
                  Get.to(() => const ClientSignUp());
                },
                FontAwesomeIcons.users,
                "Join as a client",
                "Discover and connect with professional realtors"
            )
          ],
        ),
      ),
    );
  }

  Widget userTypeCard(VoidCallback onTap, IconData iconData, String title, String subtitle) {
    return SizedBox(
      height: 25.h,
      width: 100.w,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.h),
          ),
          elevation: 3,
          color: Colors.black87,
          child: Padding(
            padding: EdgeInsets.all(2.5.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(iconData, size: 28.sp, color: const Color(0xFF80CBC4),),
                SizedBox(height: 1.5.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white54,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}

