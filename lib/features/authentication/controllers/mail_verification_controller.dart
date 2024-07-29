import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/repository/authentication_repository/authentication_repository.dart';

class MailVerificationController extends GetxController {

  late Timer _timer;

  final _auth = Get.find<AuthenticationRepository>();

  @override
  void onInit() {
    super.onInit();
    sendVerificationEmail();
    setTimerForAutoRedirect();
  }

  /// -- Send or resend email verification
  void sendVerificationEmail() async {
    try {
      await _auth.sendEmailVerification();
    } catch (e) {
      Get.snackbar("Oh Snap", e.toString());
    }
  }

  /// -- Set Timer  to check if Verification Completed then Redirect
  void setTimerForAutoRedirect() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if(user != null && user.emailVerified) {
        print("Email is now verified :?");
        timer.cancel();
        _navigateToInitialScreen();
      }
      print("Is user email verified: ${user?.emailVerified}");
    });
  }

  /// -- Manually Check if Verification Completed then Redirect
  void manuallyCheckEmailVerificationStatus() {
    FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if(user!.emailVerified) {
      _navigateToInitialScreen();
    }
  }

  void _navigateToInitialScreen() {
    // Use Get.offAll to replace all existing routes with the new page.
    Get.offAll(() => _auth.setInitialScreen());
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}