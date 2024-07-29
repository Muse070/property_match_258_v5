import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:property_match_258_v5/features/authentication/controllers/agent_controllers/agent_signup_controller.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/agent_signup_forms/agent_address_form.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/agent_signup_forms/agent_details_form.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/agent_signup_forms/agent_profile_form.dart';
import 'package:property_match_258_v5/model/user_models/agent_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../../repository/image_repository/image_repository.dart';
import '../../../../../repository/user_repository/user_repository.dart';

class AgentSignup extends StatefulWidget {
  const AgentSignup({super.key});

  @override
  State<AgentSignup> createState() => _AgentSignupState();
}

class _AgentSignupState extends State<AgentSignup> {

  final _agentSignupController = Get.find<AgentSignUpController>();
  final _imageRepo = Get.find<ImageRepository>();
  final _userRepo = Get.find<UserRepository>();

  int count = 0;

  bool _isLoading = false;

  final String _userType = 'agent';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "Agent Signup",
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
        return AgentDetailsForm(key: formKey, formKey: formKey,);
      case 1:
        return AgentAddressForm(key: formKey, formKey: formKey);
      case 2:
        return AgentProfileForm(key: formKey, formKey: formKey,); // No key is passed to the third form
    // Add more cases as needed
      default:
        return const SizedBox.shrink(); // Return an empty widget for non-existing forms
    }
  }

  Future<bool> _registerUser() async {
    UserCredential? userCredential;
    String? photoUrl;
    String? agencyUrl;
    try {
      userCredential = await _agentSignupController.registerUser(
        _agentSignupController.aEmail.text.trim(),
        _agentSignupController.aPassword.text.trim(),
      );
    } catch (e) {
      print('Error registering user and uploading user: $e');
      // Handle user registration error
      return false;
    }

    try {
      photoUrl = await _imageRepo
          .uploadProfileImageToFirebaseStorage(
          "profilePicture", _agentSignupController.profilePic, false);
    } catch (e) {
      print('Error uploading profile image: $e');
      // Handle image upload error
      return false;
    }

    try {
      agencyUrl = await _imageRepo
          .uploadProfileImageToFirebaseStorage(
          "profilePicture", _agentSignupController.agencyPic, false);
    } catch (e) {
      print('Error uploading agency image: $e');
      // Handle image upload error
      return false;
    }

    final user = AgentModel(
      userType: _userType,
      id: userCredential!.user!.uid,
      email: _agentSignupController.aEmail.text.trim(),
      lastName: _agentSignupController.aLastName.text.trim(),
      phoneNo: _agentSignupController.aPhoneNumber.text.trim(),
      password: _agentSignupController.aPassword.text.trim(),
      firstName: _agentSignupController.aFirstName.text.trim(),
      agencyName: _agentSignupController.agencyName.text.trim(),
      bio: _agentSignupController.aBio.text.trim(),
      address: _agentSignupController.aAddress.text.trim(),
      city: _agentSignupController.aCity.text.trim(),
      country: _agentSignupController.aCountry.text.trim(),
      imageUrl: photoUrl,
      agencyImage: agencyUrl,
    );

    bool result;
    try {
      result = await _agentSignupController.createAgent(user);
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
