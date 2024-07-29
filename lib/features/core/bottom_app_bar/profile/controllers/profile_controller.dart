import 'package:get/get.dart';
// import 'package:rees_app/features/core/bottom_app_bar/profile/controllers/edit_profile_controller.dart';
import 'package:property_match_258_v5/model/user_models/user_model.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';

import '../../../../../repository/authentication_repository/authentication_repository.dart';

// Use the GetxController class to create a custom controller for the user data
class ProfileController extends GetxController {
  // Use the obs property to make the user data observable and reactive
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
  ).obs;

  // Declare and initialize the user repository
  final _userRepo = Get.find<UserRepository>();
  final _authRepo = Get.find<AuthenticationRepository>();

  @override
  void onInit() async{
    super.onInit();
    fetchUserData();
  }

  // Define a method to fetch the user data from Firestore and update the controller
  Future<void> fetchUserData() async {
    try {
      // Fetch the user data from Firestore
      UserModel userData = _userRepo.currentUser.value!;
      // Update the user data in the controller
      user.value = userData;
      // Notify the UI that the user data has changed
      update();
    } catch (error) {
      // Handle the error
      print(error);
    }
  }

  // Define a method to sign out the user from the app
  Future<void> signOut() async {
    try {
      // Sign out the user from the user repository
      await _authRepo.logout();
      // Clear the user data in the controller
      user.value = UserModel(
        email: '',
        userType: '',
        lastName: '',
        phoneNo: '',
        password: '',
        id: '',
        firstName: '',
        imageUrl: null, address: '', city: '', country: '',
      );
      // Notify the UI that the user data has changed
      update();
    } catch (error) {
      // Handle the error
      print(error);
    }
  }
}
