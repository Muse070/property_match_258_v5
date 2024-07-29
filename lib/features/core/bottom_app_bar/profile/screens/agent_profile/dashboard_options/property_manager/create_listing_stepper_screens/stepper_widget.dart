import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/commercial_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/industrial_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/land_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/residential_controllers.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/create_listing_stepper_screens/review/review.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/create_listing_stepper_screens/uploads/uploads.dart';
import 'package:property_match_258_v5/model/property_models/commercial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/industrial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/land_property_model.dart';
import 'package:property_match_258_v5/repository/authentication_repository/authentication_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../../../controllers/propert_controller/property_controller.dart';
import '../../../../../../../../../model/property_models/residential_property_model.dart';
import 'details/property_type_widget.dart';
import 'location/location_widget.dart';
import 'myStep.dart';

class MyStepper extends StatefulWidget {
  const MyStepper({
    super.key,
  });

  @override
  _MyStepperState createState() => _MyStepperState();
}

class _MyStepperState extends State<MyStepper>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final ListingController _listingController = Get.find<ListingController>();
  final PropertyController _propertyController = Get.find<PropertyController>();
  final UserRepository _userRepository = Get.find<UserRepository>();


  late TabController _tabController;
  final _controller = ScrollController();

  int currentStep = 0;
  String selectedOption = '';

  bool isUploaded = false;

  List<File> imageList = [];
  List<File> docList = [];

  ValueNotifier<bool> updateNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  final propertyTypeFormKeys = <GlobalKey<FormState>>[
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final formKeys = <GlobalKey<FormState>>[
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  List<Step> getSteps() {
    List<Widget> stepWidgets = [
      PropertyType(formKey: propertyTypeFormKeys, tabController: _tabController),
      LocationWidget(formKey: formKeys[0]),
      SizedBox(height: 70.h, width: 100.w, child: Uploads(formKey: formKeys[1])),
      ReviewScreen(updateNotifier: updateNotifier),
    ];

    List<String> stepNames = [
      "Details",
      "Location",
      "Uploads",
      "Review"
    ];

    return List<Step>.generate(stepWidgets.length, (int index) {
      return Step(
        state: _listingController.currentStep.value <= index ? StepState.indexed : StepState.complete,
        isActive: _listingController.currentStep.value >= index,
        title: Text(
          stepNames[index],
          style: TextStyle(
            fontSize: 8.sp,
          ),
        ),
        content: MyStep(stepIndex: index, child: stepWidgets[index]),
      );
    });
  }

  Future<void> _uploadData() async {

    // Get the current controller based on the property type
    print("image list is ${_listingController.imageListStrDyn}");
    var imageUrls = await
    _propertyController.uploadImageListToStorage(_listingController.imageListStrDyn);

    // Upload documents to Firebase Storage and get the URLs
    var docUrls = await
    _propertyController.uploadDocListToStorage(_listingController.docListStrDyn);

    if (_listingController.currentController.value is ResidentialController) {
      var controller = (_listingController.currentController.value as ResidentialController);
      final residentialModel = ResidentialModel(
          id: const Uuid().v4(),
          agentId: _userRepository.currentUser.value!.id,
          saleOrRent: _listingController.forSaleOrRent.value,
          propertyType: _listingController.selectedPropertyType.value,
          propertyOption: _listingController.selectedPropertyOption.value,
          price: controller.price.value,
          description: controller.description.value,
          amenities: controller.mAmenities,
          address: _listingController.addressParts.value,
          city: _listingController.city.value,
          country: _listingController.country.value,
          latitude: _listingController.latitude.value,
          longitude: _listingController.longitude.value,
          images: imageUrls,
          documents: docUrls,
          numOfBedrooms: controller.numBedrooms.value,
          numOfBathrooms: controller.numBathrooms.value,
          squareMeters: controller.squareMeters.value,
          currency: _listingController.currency.value,
        furnished: false,

      );

      bool result = await
      _propertyController.addProperty(residentialModel);

      setState(() {
        isUploaded = result;
      });
    }
    else if (_listingController.currentController.value is CommercialController) {
      var controller = (_listingController.currentController.value as CommercialController);
      final commercialModel = CommercialModel(
        id: const Uuid().v4(),
        agentId: _userRepository.currentUser.value!.id,
        saleOrRent: _listingController.forSaleOrRent.value,
        propertyType: _listingController.selectedPropertyType.value,
        propertyOption: _listingController.selectedPropertyOption.value,
        price: controller.cPrice.value,
        description: controller.cDescription.value,
        amenities: controller.cAmenities,
        address: _listingController.addressParts.value,
        city: _listingController.city.value,
        country: _listingController.country.value,
        latitude: _listingController.latitude.value,
        longitude: _listingController.longitude.value,
        images: imageUrls,
        documents: docUrls,
        squareMeters: controller.cSquareMeters.value,
        numOfFloors: controller.cNumOfFloors.value,
        currency: _listingController.currency.value,
      );
      bool result = await _propertyController.addProperty(commercialModel);
      setState(() {
        isUploaded = result;
      });
    }
    else if (_listingController.currentController.value is IndustrialController) {
      var controller = (_listingController.currentController.value as IndustrialController);
      final industrialModel = IndustrialModel(
        id: const Uuid().v4(),
        agentId: _userRepository.currentUser.value!.id,
        saleOrRent: _listingController.forSaleOrRent.value,
        propertyType: _listingController.selectedPropertyType.value,
        propertyOption: _listingController.selectedPropertyOption.value,
        price: controller.iPrice.value,
        description: controller.iDescription.value,
        amenities: controller.iAmenities,
        address: _listingController.addressParts.value,
        city: _listingController.city.value,
        country: _listingController.country.value,
        latitude: _listingController.latitude.value,
        longitude: _listingController.longitude.value,
        images: imageUrls,
        documents: docUrls,
        numOfFloors: controller.iNumOfFloors.value,
        totalArea: controller.iTotalArea.value,
        areaPerFloor: controller.iAreaPerFloor.value,
        currency: _listingController.currency.value,
      );
      bool result = await _propertyController.addProperty(industrialModel);
      setState(() {
        isUploaded = result;
      });
    }
    else if (_listingController.currentController.value is LandController) {
      var controller = (_listingController.currentController.value as LandController);
      final landModel = LandModel(
        id: const Uuid().v4(),
        agentId: _userRepository.currentUser.value!.id,
        saleOrRent: _listingController.forSaleOrRent.value,
        propertyType: _listingController.selectedPropertyType.value,
        propertyOption: _listingController.selectedPropertyOption.value,
        price: controller.lPrice.value,
        description: controller.lDescription.value,
        amenities: controller.lAmenities,
        address: _listingController.addressParts.value,
        city: _listingController.city.value,
        country: _listingController.country.value,
        latitude: _listingController.latitude.value,
        longitude: _listingController.longitude.value,
        images: imageUrls,
        documents: docUrls,
        squareMeters: controller.lSquareMeters.value,
        currency: _listingController.currency.value,
      );
      bool result = await _propertyController.addProperty(landModel);
      setState(() {
        isUploaded = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Theme(
        data: ThemeData(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: Colors.black87)
        ),
        child: GetBuilder<ListingController>(
          init: ListingController(),
          builder: (controller) {
            return Stepper(
              controller: _controller,
              type: StepperType.horizontal,
              steps: getSteps(),
              currentStep: controller.currentStep.value,
              onStepContinue: () async {
                var mediaFiles = _listingController.imageListStrDyn;
                if (controller.currentStep.value == 0) {
                  // Validate the form of the currently selected tab in the PropertyType widget
                  if (propertyTypeFormKeys[_tabController.index]
                      .currentState!
                      .validate()) {
                    controller.goTo(controller.currentStep.value + 1);
                  } else {
                    Get.snackbar("Error",
                        "Please fill in all empty fields for your selected property type");
                  }
                } else if (controller.currentStep.value == 1) {
                  // Validate the form of the current step, except for the last step (ReviewScreen)
                  if (formKeys[controller.currentStep.value - 1].currentState!.validate()) {
                    controller.goTo(controller.currentStep.value + 1);
                  } else {
                    Get.snackbar("Error",
                        "Please fill in all empty fields for your selected property type");
                  }
                } else if (controller.currentStep.value == 2) {
                  // Validate the Uploads step
                  if (mediaFiles != null && mediaFiles!.isNotEmpty) {
                    controller.goTo(controller.currentStep.value + 1);
                  } else {
                    Get.snackbar(
                        "Error", "Please upload at least one image");
                  }
                } else {
                  // No validation for the last step (ReviewScreen)
                  if (controller.currentStep.value < 3) {
                    controller.goTo(controller.currentStep.value + 1);
                  } else if (controller.currentStep.value == 3) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return FutureBuilder(
                          future: _uploadData(), // Define this method to handle your data upload
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    CircularProgressIndicator(), // This is your loading widget
                                    SizedBox(height: 10),
                                    Text("Uploading..."),
                                  ],
                                ),
                              );
                            } else if (snapshot.connectionState == ConnectionState.done) {
                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Lottie.asset('assets/animation/check.json'), // Replace this with your Lottie animation
                                    const SizedBox(height: 10),
                                    const Text("Upload completed!"),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _listingController.reset();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            } else {
                              return Container(); // This is your default widget
                            }
                          },
                        );
                      },
                    );
                  }
                }
              },
              onStepCancel: () {
                if (controller.currentStep.value > 0) {
                  controller.goTo(controller.currentStep.value - 1);
                }
              },
              onStepTapped: (int index) {
                if (index > controller.currentStep.value) {
                  if (controller.currentStep.value == 0) {
                    // Validate the form of the currently selected tab in the PropertyType widget
                    if (propertyTypeFormKeys[_tabController.index]
                        .currentState!
                        .validate()) {
                      controller.goTo(index);
                    } else {
                      Get.snackbar("Error",
                          "Please fill in all empty fields for your selected property type");
                    }
                  } else if (currentStep < getSteps().length - 1) {
                    // Validate the form of the current step, except for the last step (ReviewScreen)
                    if (formKeys[currentStep - 1].currentState!.validate()) {
                      controller.goTo(index);
                    } else {
                      Get.snackbar("Error",
                          "Please fill in all empty fields for your selected property type");
                    }
                  } else {
                    // No validation for the last step (ReviewScreen)
                    controller.goTo(index);
                  }
                } else {
                  controller.goTo(index);
                }
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
            );
          }
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
