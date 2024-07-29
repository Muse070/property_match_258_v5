import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get_storage/get_storage.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/user_controller.dart';
import 'package:property_match_258_v5/repository/user_repository/agent_repository.dart';

import '../../../../../model/user_models/agent_model.dart';
import '../../../../../model/user_models/client_model.dart';
import '../../../../../model/user_models/user_model.dart';
import '../../../../../repository/user_repository/agent_repository.dart';
import '../../../../../repository/user_repository/user_repository.dart';

class EditProfileController extends GetxController {

  // Declare and initialize controllers
  final _userRepo = Get.find<UserRepository>();
  // final _imageRepo = Get.find<ImageRepository>();
  final userController = Get.find<UserController>();

  // final _agentRepo = Get.put
  late final AgentRepository _agentRepo;

  // Declare and initialize user
  final Rx<UserModel> user = UserModel(
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
      country: ''
  ).obs;

  late String imageUrl;

  // Declare Agent TextEditingControllers
  late TextEditingController emailController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController bioController;
  late TextEditingController agencyNameController;
  late TextEditingController cityController;
  late TextEditingController countryController;
  late TextEditingController addressController;



  // Declare Client TextEditingControllers
  late TextEditingController cEmailController;
  late TextEditingController cFirstNameController;
  late TextEditingController cLastNameController;
  late TextEditingController cPhoneNumberController;
  late TextEditingController cPasswordController;
  late TextEditingController cConfirmPasswordController;
  late TextEditingController cPreferencesController;
  late TextEditingController cCityController;
  late TextEditingController cCountryController;
  late TextEditingController cAddressController;

  Rx<Uint8List> profilePic = Rx<Uint8List>(Uint8List(0));
  // Rx<Uint8List> agencyPic = Rx<Uint8List>(Uint8List(0));

  final storage = GetStorage();

  bool isAgentControllersInitialized = false; // Flag to check initialization status
  bool isClientControllersInitialized = false; // Flag to check initialization status

  // Fetch the user and user image when the controller is called
  @override
  void onInit() async{
    super.onInit();
    // initState();
  }

  // Initialize the text editing controllers
  void initState() {
    // _agentRepo = Get.put(AgentRepository());
    _agentRepo = Get.find<AgentRepository>();

    print("Email Controller: ${emailController.text}");
  }

  void initializeAgentControllers(AgentModel agentData) {

    // Initialize the controllers with the user data
    bioController = TextEditingController(text: agentData.bio);
    agencyNameController = TextEditingController(text: agentData.agencyName);

    addressController = TextEditingController(text: agentData.address);
    cityController = TextEditingController(text: agentData.city);
    countryController = TextEditingController(text: agentData.country);

    emailController = TextEditingController(text: agentData.email);
    passwordController = TextEditingController(text: agentData.password);
    firstNameController = TextEditingController(text: agentData.firstName);
    lastNameController = TextEditingController(text: agentData.lastName);
    phoneNumberController = TextEditingController(text: agentData.phoneNo);

    isAgentControllersInitialized = true; // Mark as initialized


    // Update the UI when the controllers change
    bioController.addListener(() {
      update();
    });
    agencyNameController.addListener(() {
      update();
    });
    addressController.addListener(() {
      update();
    });
    cityController.addListener(() {
      update();
    });
    countryController.addListener(() {
      update();
    });
    emailController.addListener(() {
      update();
    });
    passwordController.addListener(() {
      update();
    });
    firstNameController.addListener(() {
      update();
    });
    lastNameController.addListener(() {
      update();
    });
    phoneNumberController.addListener(() {
      update();
    });
    // ... (add listeners for other controllers) ...
  }



  void initializeClientControllers(ClientModel clientData)  {

    // Initialize the controllers with the user data

    cAddressController = TextEditingController(text: clientData.address);
    cCityController = TextEditingController(text: clientData.city);
    cCountryController = TextEditingController(text: clientData.country);

    cEmailController = TextEditingController(text: clientData.email);
    cPasswordController = TextEditingController(text: clientData.password);
    cFirstNameController = TextEditingController(text: clientData.firstName);
    cLastNameController = TextEditingController(text: clientData.lastName);
    cPhoneNumberController = TextEditingController(text: clientData.phoneNo);
    cPreferencesController = TextEditingController(text: clientData.preferences);

    isClientControllersInitialized = true; // Mark as initialized


    cAddressController.addListener(() {
      update();
    });
    cPreferencesController.addListener(() {
      update();
    });
    cCityController.addListener(() {
      update();
    });
    cCountryController.addListener(() {
      update();
    });
    cEmailController.addListener(() {
      update();
    });
    cPasswordController.addListener(() {
      update();
    });
    cFirstNameController.addListener(() {
      update();
    });
    cLastNameController.addListener(() {
      update();
    });
    cPhoneNumberController.addListener(() {
      update();
    });
    // ... (add listeners for other controllers) ...
  }


  // Dispose the text editing controllers
  @override
  void onClose() {
    // Dispose the controllers when the controller is disposed
    addressController.dispose();
    cityController.dispose();
    countryController.dispose();
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    bioController.dispose();
    agencyNameController.dispose();

    cAddressController.dispose();
    cCityController.dispose();
    cCountryController.dispose();
    cEmailController.dispose();
    cPasswordController.dispose();
    cFirstNameController.dispose();
    cLastNameController.dispose();
    cPhoneNumberController.dispose();
    cPreferencesController.dispose();

    super.dispose();
  }

  // @override
  // void onReady() async {
  //   super.onReady();
  //   await fetchCurrentUserData();
  // }
  //
  // // Collect user data for currently logged in user
  // Future<void> fetchCurrentUserData() async {
  //   if (_userRepo.currentUser.value != null) {
  //     user.value = _userRepo.currentUser.value!;
  //   } else {
  //     print("User value is null");
  //   }
  //   if (kDebugMode) {
  //     print("Fetched user image url is: ${user.value.imageUrl}");
  //   }
  //
  //   // Update the text controllers with the fetched user data
  //   emailController.text = user.value.email;
  //   passwordController.text = user.value.password;
  //   firstNameController.text = user.value.firstName;
  //   lastNameController.text = user.value.lastName;
  //   phoneNumberController.text = user.value.phoneNo;
  //
  //   // Update the UI when the controllers change
  //   emailController.addListener(() {
  //     user.value.email = emailController.text;
  //   });
  //   passwordController.addListener(() {
  //     user.value.password = passwordController.text;
  //   });
  //   firstNameController.addListener(() {
  //     user.value.firstName = firstNameController.text;
  //   });
  //   lastNameController.addListener(() {
  //     user.value.lastName = lastNameController.text;
  //   });
  //   phoneNumberController.addListener(() {
  //     user.value.phoneNo = phoneNumberController.text;
  //   });
  //
  //   // Trigger an update to reflect changes in the UI
  //   update();
  // }

  // update user data
  updateUserData(UserModel user, String userType) async {
    userController.updateUser(user, userType);
  }

  // Define a method to validate and update the user data
  void validateAndUpdateUserData() async {
    // Check if the email is valid
    if (!GetUtils.isEmail(emailController.text)) {
      // Show a red snackbar with an error icon
      Get.snackbar('Error', 'Please enter a valid email', colorText: Colors.white, backgroundColor: Colors.red, icon: Icon(Icons.error));
      return;
    }
    // Check if the password is strong
    if (!GetUtils.isLengthGreaterOrEqual(passwordController.text, 6)) {
      // Show a red snackbar with an error icon
      Get.snackbar('Error', 'Password must be at least 6 characters', colorText: Colors.white, backgroundColor: Colors.red, icon: Icon(Icons.error));
      return;
    }
    // Check if the confirm password matches the password
    if (confirmPasswordController.text != passwordController.text) {
      // Show a red snackbar with an error icon
      Get.snackbar('Error', 'Passwords do not match', colorText: Colors.white, backgroundColor: Colors.red, icon: Icon(Icons.error));
      return;
    }
    // Check if the phone number is correct
    if (!GetUtils.isPhoneNumber(phoneNumberController.text)) {
      // Show a red snackbar with an error icon
      Get.snackbar('Error', 'Please enter a correct phone number', colorText: Colors.white, backgroundColor: Colors.red, icon: Icon(Icons.error));
      return;
    }
    // Save the input values to the user model
    user.value.email = emailController.text.trim();
    user.value.password = passwordController.text.trim();
    user.value.firstName = firstNameController.text.trim();
    user.value.lastName = lastNameController.text.trim();
    user.value.phoneNo = phoneNumberController.text.trim();
    user.value.imageUrl = null;
    // Update the user data in Firestore
    try {
      // await updateUserData(user.value);
      // Show a green snackbar with a check icon
      Get.snackbar('Success', 'Your information has been updated', colorText: Colors.white, backgroundColor: Colors.green, icon: Icon(Icons.check));
    } catch (error) {
      // Handle specific errors or provide a generic error message
      if (error is FirebaseException) {
        if (error.code == 'not-found') {
          // Handle 'not found' error
          Get.snackbar('Error', 'Document not found', colorText: Colors.white, backgroundColor: Colors.red, icon: const Icon(Icons.error));
        } else if (error.code == 'permission-denied') {
          // Handle 'permission denied' error
          Get.snackbar('Error', 'Permission denied', colorText: Colors.white, backgroundColor: Colors.red, icon: const Icon(Icons.error));
        } else {
          // Handle other Firebase-related errors
          Get.snackbar('Error', 'Something went wrong.', colorText: Colors.white, backgroundColor: Colors.red, icon: const Icon(Icons.error));
        }
      } else {
        // Handle generic errors
        Get.snackbar('Error', 'Unknown error.', colorText: Colors.white, backgroundColor: Colors.red, icon: const Icon(Icons.error));
      }
    }
  }

}
