import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_match_258_v5/features/authentication/controllers/client_controllers/client_signup_controller.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/client_signup_forms/client_address_form.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/client_signup_forms/client_details_form.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/client_signup_forms/client_profile_form.dart';
import 'package:property_match_258_v5/model/user_models/client_model.dart';
import 'package:property_match_258_v5/model/user_models/user_model.dart';
import 'package:property_match_258_v5/widgets/elevated_button_widget.dart';
import 'package:property_match_258_v5/widgets/text_field_widget.dart';
import 'package:sizer/sizer.dart';

import '../../../../../repository/image_repository/image_repository.dart';
import '../../../../../repository/user_repository/user_repository.dart';
import '../../../../../utils/pick_image.dart';

class ClientSignUp extends StatefulWidget {
  const ClientSignUp({super.key});

  @override
  State<ClientSignUp> createState() => _ClientSignUpForm();
}

class _ClientSignUpForm extends State<ClientSignUp> {
  final GlobalKey<FormState> clientFormKey = GlobalKey<FormState>();
  final _clientSignupController = Get.find<ClientSignUpController>();
  final _imageRepo = Get.find<ImageRepository>();
  final _userRepo = Get.find<UserRepository>();

  int count = 0;

  bool _isLoading = false;

  final String _userType = 'client';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Client Signup",
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
                color: Colors.white
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Container(
          child: Theme(
            data: ThemeData(
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(primary: Colors.black87)
            ),
            child: _isLoading ? const Center(child: CircularProgressIndicator()) : Stepper(
              // type: StepperType.horizontal,
              steps: getSteps(),
              currentStep: count,
              onStepContinue: () async {
                if (count <= titles.length - 2 && formKeys[count].currentState!.validate()) { // Only validate the first two steps
                  setState(() {
                    if (count < titles.length - 1) {
                      count++;
                    }
                  });
                } else if (count == titles.length - 1) { // For the final step
                  if (formKeys[count].currentState!.validate()) { // Validate the final step
                    setState(() {
                      _isLoading = true;
                    });

                    bool registrationSuccessful = await _registerUser();

                    setState(() {
                      _isLoading = false;
                    });

                    if (registrationSuccessful) {
                      // Navigate to a different screen or show a success message
                    } else {
                      // Show an error message
                    }
                  }
                }
              },
              onStepCancel: () {
                setState(() {
                  if (count > 0) {
                    count--;
                  }
                });
              },
              controlsBuilder:
                  (BuildContext context, ControlsDetails controlsDetails) {
                return Row(
                  children: <Widget>[
                    SizedBox(
                      width: 26.w,
                      child: TextButton(
                        onPressed: controlsDetails.onStepCancel,
                        style: ButtonStyle(
                            shape: MaterialStateProperty
                                .all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.w),
                                side: const BorderSide(color: Colors.black)))),
                        child: const Text('Back'),
                      ),
                    ),
                    SizedBox(
                      width: 1.5.w,
                    ),
                    ElevatedButton(
                      onPressed: controlsDetails.onStepContinue,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.black87),
                        foregroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white),
                      ),
                      child: const Text('CONTINUE'),
                    ),
                  ],
                );
              },
            ),
          )
      ),
    );
  }

  List<String> titles = ['Personal Details', 'Home Address', 'Profile',];

  List<GlobalKey<FormState>> formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()]; // Add more keys as needed

  List<Step> getSteps() {
    List<Step> steps = [];
    for (int i = 0; i < titles.length; i++) {
      steps.add(
        Step(
          state: count > i ? StepState.complete : StepState.indexed,
          title: Text(titles[i]),
          content: getContentForm(i, formKeys[i]), // Pass the key to all forms
          isActive: count >= i, // You can control this based on your step's state
        ),
      );
    }
    return steps;
  }

  Widget getContentForm(int index, GlobalKey<FormState> formKey) {
    switch (index) {
      case 0:
        return ClientDetailsForm(key: formKey, formKey: formKey,);
      case 1:
        return ClientAddressForm(key: formKey, formKey: formKey);
      case 2:
        return ClientProfileForm(key: formKey, formKey: formKey);
      default:
        return const SizedBox.shrink(); // Return an empty widget for non-existing forms
    }
  }

  Future<bool> _registerUser() async {
    UserCredential? userCredential;
    String? photoUrl;
    try {
      userCredential = await _clientSignupController.registerUser(
        _clientSignupController.email.text.trim(),
        _clientSignupController.password.text.trim(),
      );
    } catch (e) {
      print('Error registering user and uploading user: $e');
      // Handle user registration error
      return false;
    }

    try {
      photoUrl = await _imageRepo
          .uploadProfileImageToFirebaseStorage(
          "profilePicture", _clientSignupController.profilePic, false);
    } catch (e) {
      print('Error uploading profile image: $e');
      // Handle image upload error
      return false;
    }

    final user = ClientModel(
      userType: _userType,
      id: userCredential!.user!.uid,
      email: _clientSignupController.email.text.trim(),
      lastName: _clientSignupController.lastName.text.trim(),
      phoneNo: _clientSignupController.phoneNumber.text.trim(),
      password: _clientSignupController.password.text.trim(),
      firstName: _clientSignupController.firstName.text.trim(),
      address: _clientSignupController.address.text.trim(),
      city: _clientSignupController.city.text.trim(),
      country: _clientSignupController.country.text.trim(),
      preferences: _clientSignupController.bio.text.trim(),
      imageUrl: photoUrl,
    );

    bool result;
    try {
      result = await _clientSignupController.createClient(user);
      print("User creation result is: $result");
    } catch (e) {
      print('Error creating agent: $e');
      // Handle client creation error
      return false;
    }

    try {
      await _userRepo.updateUser(user, "clients");
    } catch (e) {
      print('Error updating user: $e');
      // Handle user update error
      return false;
    }

    return true;
  }
}
