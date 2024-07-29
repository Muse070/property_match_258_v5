import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';

class MyStep extends StatelessWidget {
  final int stepIndex;
  final Widget child;

  MyStep({required this.stepIndex, required this.child});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingController>(
      builder: (controller) {
        if (controller?.currentStep.value == stepIndex) {
          return child;
        } else {
          return Container(); // Return an empty container for steps that are not active
        }
      },
    );
  }
}
