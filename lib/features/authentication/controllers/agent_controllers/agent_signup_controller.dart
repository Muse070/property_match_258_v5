import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../model/user_models/user_model.dart';
import '../../../../repository/authentication_repository/authentication_repository.dart';
import '../../../../repository/user_repository/user_repository.dart';

class AgentSignUpController extends GetxController {
  static AgentSignUpController get instance => Get.find();


  final _userRepo = Get.find<UserRepository>();
  final _auth = Get.find<AuthenticationRepository>();


  // Details
  late TextEditingController aEmail;
  late TextEditingController aFirstName;
  late TextEditingController aLastName;
  late TextEditingController aPassword;
  late TextEditingController aConfirmPassword;
  late TextEditingController aPhoneNumber;

  // Address
  late TextEditingController aAddress;
  late TextEditingController aCity;
  late TextEditingController aCountry;

  // Images
  Uint8List profilePic = Uint8List(0);
  Uint8List agencyPic = Uint8List(0);

  // Agency
  late TextEditingController agencyName;

  // Bio
  late TextEditingController aBio;

  @override
  void onInit() {
    super.onInit();
    aEmail = TextEditingController();
    aFirstName = TextEditingController();
    aLastName = TextEditingController();
    aPassword = TextEditingController();
    aConfirmPassword = TextEditingController();
    aPhoneNumber = TextEditingController();
    aAddress = TextEditingController();
    aCity = TextEditingController();
    aCountry = TextEditingController();
    agencyName = TextEditingController();
    aBio = TextEditingController();
  }

  @override
  void onClose() {
    aEmail.dispose();
    aFirstName.dispose();
    aLastName.dispose();
    aPhoneNumber.dispose();
    aPassword.dispose();
    aConfirmPassword.dispose();
    aAddress.dispose();
    aCity.dispose();
    aCountry.dispose();
    agencyName.dispose();
    aBio.dispose();
    super.onClose();
  }

  Future<bool> createAgent(UserModel user) async {
    return await _userRepo.createUser(user, "agents");
  }

  Future<UserCredential> registerUser(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email,
      password,
    );
  }

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
      if (value != aPassword.text) {
        return 'Password and confirm password do not match';
      }
    }
    // Return null if there is no error
    return null;
  }

}