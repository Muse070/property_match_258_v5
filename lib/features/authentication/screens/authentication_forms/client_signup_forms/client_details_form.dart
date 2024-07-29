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

class ClientDetailsForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const ClientDetailsForm({required Key key, required this.formKey}) : super(key: key);

  @override
  State<ClientDetailsForm> createState() => _ClientDetailsFormState();
}

class _ClientDetailsFormState extends State<ClientDetailsForm> {
  // final agentFormKey = GlobalKey<FormState>();
  final _signUpController = Get.find<ClientSignUpController>();


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
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            height: 0.5.h,
          ),
          TextBarWidget(
            textEditingController: _signUpController.firstName,
            label: "First Name",
            iconData: Icons.person_2_outlined,
            validatorError: "Please enter your first name",
            isPassword: false,
          ),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
            textEditingController: _signUpController.lastName,
            label: "Last Name",
            validatorError: "Please enter your last name",
            isPassword: false,
          ),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
            textEditingController: _signUpController.email,
            label: "Email",
            iconData: Icons.email_outlined,
            validatorError: "Please enter your email",
            isPassword: false,
          ),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
              textEditingController: _signUpController.password,
              label: "Password",
              validatorError: "Please enter your password",
              isPassword: true),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
              textEditingController: _signUpController.confirmPassword,
              label: "Confirm Password",
              validatorError: "Please confirm your password",
              isPassword: true),
          SizedBox(
            height: 1.5.h,
          ),
          TextBarWidget(
            textEditingController: _signUpController.phoneNumber,
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
