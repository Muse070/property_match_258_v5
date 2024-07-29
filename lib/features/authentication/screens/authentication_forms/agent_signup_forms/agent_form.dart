import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_match_258_v5/features/authentication/controllers/signup_controller.dart';
import 'package:property_match_258_v5/model/user_models//user_model.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:property_match_258_v5/utils/pick_image.dart';
import 'package:property_match_258_v5/widgets/elevated_button_widget.dart';
import 'package:property_match_258_v5/widgets/text_field_widget.dart';

import '../../../../../repository/image_repository/image_repository.dart';

class AgentSignUpForm extends StatefulWidget {
  const AgentSignUpForm({super.key});

  @override
  State<AgentSignUpForm> createState() => _AgentSignUpFormState();
}

class _AgentSignUpFormState extends State<AgentSignUpForm> {
  final agentFormKey = GlobalKey<FormState>();
  final _signUpController = Get.find<SignUpController>();
  final _userRepo = Get.find<UserRepository>();
  final _imageRepo = Get.find<ImageRepository>();

  bool isLoading = false;
  Uint8List? _image;

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create and return the form for client sign-up
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SizedBox(
            width: MediaQuery.of(context).size.width, child: _buildForm1()));
  }

  Widget _buildForm1() {
    const String userType = 'agent';

    return Form(
      key: agentFormKey,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(
            height: 25,
          ),
          Stack(
            children: [
              _image != null
                  ? CircleAvatar(
                      radius: 60,
                      backgroundImage: MemoryImage(_image!),
                    )
                  : const CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xff34c0b3),
                      child: Icon(
                        Icons.person,
                        color: Colors.black87,
                        size: 45,
                      ),
                    ),
              Positioned(
                bottom: -10,
                left: 80,
                child: IconButton(
                  onPressed: () {
                    selectImage();
                  },
                  icon: const Icon(Icons.add_a_photo),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            "Agent Form",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          const SizedBox(
            height: 15,
          ),
          TextBarWidget(
            textEditingController: _signUpController.aFirstName,
            label: "First Name",
            iconData: Icons.person_2_outlined,
            validatorError: "Please enter your first name",
            isPassword: false,
          ),
          const SizedBox(
            height: 15,
          ),
          TextBarWidget(
            textEditingController: _signUpController.aLastName,
            label: "Last Name",
            validatorError: "Please enter your last name",
            isPassword: false,
          ),
          const SizedBox(
            height: 15,
          ),
          TextBarWidget(
            textEditingController: _signUpController.aEmail,
            label: "Email",
            iconData: Icons.email_outlined,
            validatorError: "Please enter your email",
            isPassword: false,
          ),
          const SizedBox(
            height: 15,
          ),
          TextBarWidget(
              textEditingController: _signUpController.aPassword,
              label: "Password",
              validatorError: "Please enter your password",
              isPassword: true),
          const SizedBox(
            height: 15,
          ),
          TextBarWidget(
              textEditingController: _signUpController.aConfirmPassword,
              label: "Confirm Password",
              validatorError: "Please confirm your password",
              isPassword: true),
          const SizedBox(
            height: 15,
          ),
          TextBarWidget(
            textEditingController: _signUpController.aPhoneNumber,
            label: "Phone Number",
            iconData: Icons.phone,
            validatorError: "Please confirm your phone number",
            isPassword: false,
          ),
          const SizedBox(
            height: 25,
          ),
          ElevatedButtonWidget(
            formKey: agentFormKey,
            controller: _signUpController,
            onTap: () async {
              if (agentFormKey.currentState!.validate()) {
                setState(() {
                  isLoading = true;
                });
                try {
                  final UserCredential userCredential =
                  await _signUpController.registerUser(
                    _signUpController.aEmail.text.trim(),
                    _signUpController.aPassword.text.trim(),
                  );

                  String? photoUrl = await _imageRepo
                      .uploadProfileImageToFirebaseStorage(
                      "profilePicture", _image!, false);

                  final user = UserModel(
                    email: _signUpController.aEmail.text.trim(),
                    userType: userType,
                    lastName: _signUpController.aLastName.text.trim(),
                    phoneNo: _signUpController.aPhoneNumber.text.trim(),
                    password: _signUpController.aPassword.text.trim(),
                    firstName: _signUpController.aFirstName.text.trim(),
                    id: userCredential.user!.uid,
                    imageUrl: photoUrl,
                    address: '',
                    city: '',
                    country: '',
                  );

                  await _signUpController.createUser(user);
                  _userRepo.updateUser(user, user.userType);
                } catch (e) {
                  setState(() {
                    isLoading = false;
                  });
                }

                setState(() {
                  isLoading = false;
                });
              }
            },
            isLoading: isLoading,
            buttonText: "Sign Up",
          ),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
