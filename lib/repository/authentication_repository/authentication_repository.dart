import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:property_match_258_v5/exceptions/exceptions.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/auth_login.dart';
import 'package:property_match_258_v5/features/authentication/screens/mail_verification/mail_verification.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/main_page.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';

import '../../controllers/favoritesController/favorites_controller.dart';
import '../../exceptions/exceptions.dart';
import '../../features/authentication/screens/authentication_forms/auth_login.dart';
import '../../features/authentication/screens/forget_password/forget_password_otp/forget_password_otp.dart';
import '../../features/authentication/screens/mail_verification/mail_verification.dart';
import '../../features/core/bottom_app_bar/main_page.dart';
import '../../utils/local_storage.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  // final UserRepository _userRepository = Get.find<UserRepository>();
  //Variables
  final _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  var verificationId = ''.obs;

  User? get currentUser => _auth.currentUser;

  final RxBool isLoading = false.obs;
  RxBool showResendButton = false.obs; // Observable to control resend button visibility
  Timer? _resendTimer;


  @override
  void onInit() {
    super.onInit();
    // Listen to changes in authentication state

    _auth.authStateChanges().listen((User? user) {
      firebaseUser.value = user;
      setInitialScreen();
    });
  }

  String setInitialScreen() {
    final user = currentUser;

    if (user == null) {
      return '/';
    } else {
      if (user.emailVerified) {
        return '/mainPage';
      } else {
        return '/mailVerification';
      }
    }
  }

  Future<void> sendPasswordResetCode(String phoneNumber) async {
    try {
      isLoading.value = true; // Start loading

      print("Starting process for getting code");

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          print("Credentials are $credential");
          print("Intended phone number is: $phoneNumber");
          print("Verification is complete");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("We're facing some errors");
          print("Intended phone number is: $phoneNumber");
          print("Error is ${e.code}");
          Get.snackbar(
              'Error',
              'An error occurred. ${e.code}'
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          print("The code is: ${this.verificationId.value}");
          this.verificationId.value = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-phone-number') {
        Get.snackbar('Error', 'The provided phone number is not valid.');
      } else if (e.code == 'too-many-requests') {
        Get.snackbar('Error', 'Too many requests. Please try again later.');
      } else {
        // Catch all other FirebaseAuthExceptions
        Get.snackbar('Error', 'An error occurred: ${e.message}');
        print(e.message);

      }
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.dialog(
        AlertDialog(
          title: const Text('Password Reset'),
          content: const Text('An email has been sent with instructions to reset your password.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      _startResendTimer();
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (e.code == 'user-not-found') {
        Get.snackbar('Error', 'No user found with that email.');
      } else if (e.code == 'invalid-email') {
        Get.snackbar('Error', 'Invalid email address.');
      } else {
        // General Firebase error
        Get.snackbar('Error', 'Failed to send password reset email. Please try again later.');
      }
    } catch (e) {
      // Handle any other unexpected errors
      print('Error sending password reset email: $e');
      Get.snackbar('Error', 'An unexpected error occurred. Please try again later.');
    }
  }

  void _startResendTimer() {
    showResendButton.value = false; // Hide the resend button initially
    _resendTimer = Timer(const Duration(seconds: 30), () {
      showResendButton.value = true; // Show the resend button after 30 seconds
    });
  }

  // Method to resend the password reset email
  Future<void> resendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Password Reset',
        'The email has been resent.',
        snackPosition: SnackPosition.BOTTOM,
      );
      // Restart the timer if the user resends the email
      _startResendTimer();
    } on FirebaseAuthException catch (e) {
      // ... (your existing error handling) ...
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel(); // Cancel the timer when the controller is disposed
    super.onClose();
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);
      throw ex.message;
    } catch (_) {
      const ex = TExceptions();
      throw ex.message;
    }
  }

  // Future<void> verifyResetPasswordCode(String code, String email, String newPassword) async { // Added newPassword parameter
  //   try {
  //     // 1. Fetch sign-in methods for the email
  //     List<String> signInMethods = await _auth.fetchSignInMethodsForEmail(email);
  //
  //     // 2. Verify the code
  //     if (signInMethods.contains('password')) {
  //       try {
  //         await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  //         Get.snackbar("Success", "Password reset successful!");
  //
  //         // Optional: Navigate to a success screen or login
  //         // Get.offAll(LoginScreen()); // Example navigation
  //       } on FirebaseAuthException catch (e) {
  //         if (e.code == 'invalid-action-code') {
  //           Get.snackbar('Error', 'Invalid or expired verification code.');
  //         } else {
  //           Get.snackbar('Error', 'An error occurred during password reset. Please try again.'); // More specific error message
  //         }
  //       }
  //     } else {
  //       // User didn't sign in with email/password
  //       Get.snackbar('Error', 'No user found with that email or password.');
  //     }
  //   } catch (e) {
  //     // 5. Handle any other potential errors
  //     print('Error during password reset verification: $e'); // Log the error for debugging
  //     Get.snackbar('Error', 'An error occurred. Please try again.');
  //   }
  // }

  Future<bool> verifyOTP(String otp) async {
    var credentials = await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
            verificationId: verificationId.value, smsCode: otp));
    print(credentials.user);
    return credentials.user != null ? true : false;
  }


  void sendVerificationCode(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      Get.snackbar('Error', 'Please enter your phone number.');
      return;
    }

    try {
      isLoading.value = true;
      await sendPasswordResetCode(phoneNumber);
      print("Managed to get through this point");
      Get.to(() => OTPScreen(email: ""));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-phone-number') {
        Get.snackbar('Error', 'The provided phone number is not valid.');
      } else {
        // Catch all other FirebaseAuthExceptions
        Get.snackbar('Error', 'An error occurred: ${e.message}');
        print(e.message);
      }
      print('Error sending password reset code: $e'); // Log the error for debugging
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while sending the code.');
      print('Error sending password reset code: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = _auth.currentUser;
      if (user != null) {
        await TLocalStorage.init(user.uid);
        Get.put(FavoriteController());
        Get.to(() => MailVerification());
      } else {
        Get.to(() => const AuthLogin());
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);
      Get.snackbar("Error", ex.message, snackPosition: SnackPosition.BOTTOM);
      if (kDebugMode) {
        print('FIREBASE AUTH EXCEPTION - ${ex.message}');
      }
      throw ex;
    } catch (_) {
      const ex = TExceptions();
      Get.snackbar("Error", ex.message);
      throw ex;
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = _auth.currentUser;
      if (user != null) {
        await TLocalStorage.init(user.uid);
      }
      Get.offAll(() => const MainPage());
      Get.put(FavoriteController()); // Reinitialize FavoriteController here
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar("Error", "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        print("FirebaseAuthException: ${e.code}, ${e.message}");
        Get.snackbar("Error", "Wrong password.");
      } else {
        print("FirebaseAuthException: ${e.code}, ${e.message}");
        Get.snackbar("Error", "$e");
      }
      print(e);
    } catch (error) {
      print('Error: $error');
      Get.snackbar("Error", "An unexpected error occurred. $error");
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      // await TLocalStorage.instance().clearAll();
      Get.delete<FavoriteController>(); // Delete the FavoriteController
      Get.put(FavoriteController()); // Reinitialize FavoriteController here
      Get.offAll(() => const AuthLogin());
    } on Exception catch (e) {

      print('Error: $e');
      Get.snackbar("Error", "An unexpected error occurred.");
    }
  }

}
