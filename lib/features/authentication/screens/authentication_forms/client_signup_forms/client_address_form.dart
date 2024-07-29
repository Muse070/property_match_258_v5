import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:property_match_258_v5/features/authentication/controllers/agent_controllers/agent_signup_controller.dart';
import 'package:property_match_258_v5/features/authentication/controllers/client_controllers/client_signup_controller.dart';
import 'package:property_match_258_v5/widgets/text_field_widget.dart';
import 'package:sizer/sizer.dart';

class ClientAddressForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const ClientAddressForm({required Key key, required this.formKey}) : super(key: key);


  @override
  State<ClientAddressForm> createState() => _ClientAddressFormState();
}

class _ClientAddressFormState extends State<ClientAddressForm> {
  final _clientSignupController = Get.find<ClientSignUpController>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 0.5.h,
            ),
            TextBarWidget(
              textEditingController: _clientSignupController.address,
              isPassword: false,
              hintText: "Address",
              label: "Address",
              iconData: Icons.home,
              validatorError: "Please enter address",
            ),
            SizedBox(
              height: 1.5.h,
            ),
            TextBarWidget(
              textEditingController: _clientSignupController.city,
              isPassword: false,
              hintText: "City",
              label: "City",
              iconData: Icons.location_city_outlined,
              validatorError: "Please enter city",
            ),
            SizedBox(
              height: 1.5.h,
            ),
            TextBarWidget(
              textEditingController: _clientSignupController.country,
              isPassword: false,
              hintText: "Country",
              label: "Country",
              iconData: Icons.flag,
              validatorError: "Please enter country",
            ),
            SizedBox(
              height: 1.5.h,
            ),
          ],
        )
    );
  }
}
