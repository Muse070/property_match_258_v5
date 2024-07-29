import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/main_page.dart';
import 'package:property_match_258_v5/repository/authentication_repository/authentication_repository.dart';

class OTPController extends GetxController {
  static OTPController get instance => Get.find();

  final AuthenticationRepository _auth = Get.find<AuthenticationRepository>();
  final _isLoading = false.obs;

  RxBool get isLoading => _isLoading;

  // You don't need isVerified for email-based password reset
  // No need for the isOTPVerified function in this scenario either

  void verifyOTP(String otpCode, String email) async {
    _isLoading.value = true; // Show loading state

    try {
      // Assuming your auth repository has a method to verify OTP and email
      // await _auth.verifyResetPasswordCode(otpCode, email);

      // Verification successful - Navigate to the new password screen
      // Get.offAll(const NewPasswordScreen()); // Assuming you have a NewPasswordScreen
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors
      if (e.code == 'invalid-action-code') {
        Get.snackbar('Error', 'Invalid or expired verification code.');
      } else if (e.code == 'user-disabled') {
        Get.snackbar('Error', 'User account disabled.');
      } else {
        Get.snackbar('Error', 'An error occurred during password reset.');
      }
    } catch (e) {
      // Handle other errors
      Get.snackbar('Error', 'An unexpected error occurred.');
    } finally {
      _isLoading.value = false; // Hide loading state
    }
  }
}
