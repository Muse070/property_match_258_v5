import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/model/user_models/user_model.dart';
import 'package:property_match_258_v5/repository/authentication_repository/authentication_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';

class ClientSignUpController extends GetxController {
  static ClientSignUpController get instance => Get.find();

  final _userRepo = Get.find<UserRepository>();
  final _auth = Get.find<AuthenticationRepository>();

  late Rx<UserModel?> currentUser;

  // Image
  Uint8List profilePic = Uint8List(0);

  //Text field Controllers to get data from TextFields
  late TextEditingController email;
  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController phoneNumber;
  late TextEditingController password;
  late TextEditingController confirmPassword;

  // Address
  late TextEditingController address;
  late TextEditingController city;
  late TextEditingController country;

  // Bio
  late TextEditingController bio;



  @override
  void onInit() {
    super.onInit();
    email = TextEditingController();
    firstName = TextEditingController();
    lastName = TextEditingController();
    phoneNumber = TextEditingController();
    password = TextEditingController();
    confirmPassword = TextEditingController();
    address = TextEditingController();
    city = TextEditingController();
    country = TextEditingController();
    bio = TextEditingController();

  }

  @override
  void onClose() {
    email.dispose();
    firstName.dispose();
    lastName.dispose();
    password.dispose();
    confirmPassword.dispose();
    phoneNumber.dispose();
    address.dispose();
    city.dispose();
    country.dispose();
    bio.dispose();
    super.onClose();
  }

  Future<UserCredential> registerUser(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email,
      password,
    );
  }

  Future<bool> createClient(UserModel user) async {
    return await _userRepo.createUser(user, "clients");
  }

  // void phoneAuthentication(String phoneNo) {
  //   _auth.phoneAuthentication(phoneNo);
  // }

  String? validator(String? value, String field) {
    // Check if the value is null or empty
    if (value == null || value.isEmpty) {
      return 'Please enter $field';
    }
    // Check if the field is email
    if (field == 'email') {
      // Use a regular expression to validate the email format
      RegExp emailRegex = RegExp(
          r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email';
      }
    }
    // Check if the field is password
    if (field == 'password') {
      // Use the GetUtils class to check if the password is strong enough
      if (!GetUtils.isLengthGreaterOrEqual(value, 8)) {
        return 'Password must be at least 8 characters long';
      }
      if (!GetUtils.hasCapitalletter(value)) {
        return 'Password must contain at least one uppercase letter';
      }
      // if (!GetUtils.hasNumber(value)) {
      //   return 'Password must contain at least one number';
      // }
      if (!GetUtils.hasMatch(value, r'[!@#$%^&*(),.?":{}|<>]')) {
        return 'Password must contain at least one special character';
      }
    }
    // Check if the field is confirm password
    if (field == 'confirm password') {
      // Compare the value with the password field
      if (value != password.text) {
        return 'Password and confirm password do not match';
      }
    }
    // Return null if there is no error
    return null;
  }
}
