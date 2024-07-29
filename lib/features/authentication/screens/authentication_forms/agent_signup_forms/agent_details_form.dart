import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_match_258_v5/features/authentication/controllers/agent_controllers/agent_signup_controller.dart';
import 'package:property_match_258_v5/features/authentication/controllers/client_controllers/client_signup_controller.dart';
import 'package:property_match_258_v5/model/user_models/agent_model.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:property_match_258_v5/utils/pick_image.dart';
import 'package:property_match_258_v5/widgets/elevated_button_widget.dart';
import 'package:property_match_258_v5/widgets/text_field_widget.dart';
import 'package:sizer/sizer.dart';

import '../../../../../repository/image_repository/image_repository.dart';

class AgentDetailsForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const AgentDetailsForm({required Key key, required this.formKey}) : super(key: key);

  @override
  State<AgentDetailsForm> createState() => _AgentDetailsFormState();
}

class _AgentDetailsFormState extends State<AgentDetailsForm> {
  // final agentFormKey = GlobalKey<FormState>();
  final _signUpController = Get.find<AgentSignUpController>();


  @override
  Widget build(BuildContext context) {

    // Create and return the form for client sign-up
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SizedBox(
            width: 100.w,
            child: _buildForm1()
        )
    );
  }

  Widget _buildForm1() {
    const String userType = 'agent';

    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            height: 0.5.h,
          ),
          TextBarWidget(
            textEditingController: _signUpController.aFirstName,
            label: "First Name",
            iconData: Icons.person_2_outlined,
            validatorError: "Please enter your first name",
            isPassword: false,
          ),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
            textEditingController: _signUpController.aLastName,
            label: "Last Name",
            validatorError: "Please enter your last name",
            isPassword: false,
          ),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
            textEditingController: _signUpController.aEmail,
            label: "Email",
            iconData: Icons.email_outlined,
            validatorError: "Please enter your email",
            isPassword: false,
          ),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
              textEditingController: _signUpController.aPassword,
              label: "Password",
              validatorError: "Please enter your password",
              isPassword: true),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
              textEditingController: _signUpController.aConfirmPassword,
              label: "Confirm Password",
              validatorError: "Please confirm your password",
              isPassword: true),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
            textEditingController: _signUpController.aPhoneNumber,
            label: "Phone Number",
            iconData: Icons.phone,
            validatorError: "Please confirm your phone number",
            isPassword: false,
          ),
          SizedBox(
            height: 1.5.h,
          ),
        ]),
      ),
    );
  }
}
