// Use the GetxController class to create a custom controller for the user data
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/model/user_models/agent_model.dart';

import '../../../../../model/user_models/user_model.dart';
import '../../../../../repository/user_repository/user_repository.dart';

class UserController extends GetxController {
  // Use the obs property to make the user data observable and reactive
  final _userRepo = Get.find<UserRepository>();
  var user = UserModel(
    email: '',
    userType: '',
    lastName: '',
    phoneNo: '',
    password: '',
    id: '',
    firstName: '',
    imageUrl: null,
    address: '',
    city: '',
    country: '',
    propertyIds: [],
  ).obs;



  // Future<UserModel> _getUserDetails() async {
  //   final user = await _userRepo.currentUser;
  //   return user;
  // }

  // Define a method to update the user data in Firestore and in the controller
  Future<void> updateUser(UserModel newUser, String userType) async {
    try {
      // Update the user data in Firestore
      await _userRepo.updateUser(newUser, userType);
      // Update the user data in the controller
      user.value = newUser;
      // Notify the UI that the user data has changed
      update();
    } catch (error) {
      // Handle the error
      if (kDebugMode) {
        print(error);
      }
    }
  }
}