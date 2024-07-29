import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/create_listing_stepper_screens/stepper_widget.dart';
import 'package:sizer/sizer.dart';

class CreateNewListing extends StatelessWidget {
  const CreateNewListing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: IconTheme(
            data: IconThemeData(
              size: 12.sp,
              color: Colors.white,
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Create Listing",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            fontFamily: "Roboto",
          ),
        ),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        color: Colors.grey.shade200,
          child: const MyStepper()
      ),
    );
  }
}
