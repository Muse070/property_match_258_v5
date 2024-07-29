import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/commercial_step_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/edit_property_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/industrial_step_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/land_step_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/listing_manager/property_edit_steps/details_steps/commercial_details_step.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/listing_manager/property_edit_steps/details_steps/industrial_details_step.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/listing_manager/property_edit_steps/details_steps/land_details_step.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/listing_manager/property_edit_steps/details_steps/residential_details_step.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/listing_manager/property_edit_steps/images_step/images_step.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/listing_manager/property_edit_steps/location_step/location_step.dart';
import 'package:property_match_258_v5/model/property_models/commercial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/industrial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/land_property_model.dart';
import 'package:property_match_258_v5/model/property_models/property_model.dart';
import 'package:property_match_258_v5/model/property_models/residential_property_model.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../controllers/favoritesController/favorites_controller.dart';
import '../../../../../../../../../controllers/propert_controller/property_controller.dart';
import '../../../../../controllers/edit_property_step_controllers/residential_step_controller.dart';

class EditProperty extends StatefulWidget {
  final PropertyModel property;

  const EditProperty({super.key, required this.property});

  @override
  State<EditProperty> createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
  int currentStep = 0;

  final _formKey = GlobalKey<FormState>();
  bool isUploaded = false;

  late EditPropertyController _editPropertyController;
  final PropertyController _propertyController = Get.find<PropertyController>();
  final FavoriteController _favoriteController = Get.find<FavoriteController>();

  final _userRepo = Get.find<UserRepository>();

  // Function to define custom splash color
  MaterialAccentColor? customSplash(MaterialState state) {
    if (state == MaterialState.pressed) {
      return Colors.blueAccent; // Set custom splash color (adjust as needed)
    }
    return null; // No color for other states
  }

  @override
  void initState() {
    super.initState();
    Get.put<EditPropertyController>(EditPropertyController(widget.property));
    _editPropertyController = Get.find<EditPropertyController>();
  }

  // Helper function to check if a string is valid Base64
  bool _isBase64(String str) {
    try {
      base64Decode(str); // Attempt to decode
      return true; // If no error, it's likely Base64
    } catch (e) {
      return false; // If an error occurs, it's not Base64
    }
  }

  Future<void> _uploadData() async {

    try {
      print("Getting ready to start update");
      // print("_edit properties is: ${_editPropertyController.imageListStrDyn}");
      print("New strDyn is: ${_editPropertyController.docListStrDyn}");


      try {
        print("Contents of image List: ${_editPropertyController.newImages}");
      }  on PlatformException catch (e) {
        print("Error selecting images/videos: $e");
        Get.snackbar(
            "Error", "Could not select images/videos.",
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        // Catch general exceptions
        print("Unexpected error: $e");
        Get.snackbar(
            "Error", "An unexpected error occurred.",
            snackPosition: SnackPosition.BOTTOM);
      }

      // print("! _edit properties is: ${imageUrls}");


      print("Just completed decode");

      late final List<String> imageUrls;


      try {
        imageUrls = await _propertyController.uploadImageListToStorage(_editPropertyController.newImages);
        print("More contents of image List: ${_editPropertyController.imageListStrDyn}");
        print("Image urls are: $imageUrls");
      }  on PlatformException catch (e) {
        print("Error selecting images/videos: $e");
        Get.snackbar(
            "Error", "Could not select images/videos.",
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        // Catch general exceptions
        print("Unexpected error: $e");
        Get.snackbar(
            "Error", "An unexpected error occurred.",
            snackPosition: SnackPosition.BOTTOM);
      }

      await _editPropertyController.decodeImageListBase64();
      _editPropertyController.decodeBase64();

      // print("New strDyn is: ${_editPropertyController.docListStrDyn}");

      late final List<String> docUrls;

      // late final List<String> imageUrls;

      try {
        docUrls = await _propertyController.uploadDocListToStorage(_editPropertyController.docListStrDyn);
        // imageUrls = await _propertyController.uploadImageListToStorage(_editPropertyController.imageListStrDyn);
      } on Exception catch (e) {
        print("Error: $e");
      }

      print(
          "Here is the list of docStrDyn URLs: $docUrls");


      print(
          "Here is the list of docStrDyn URLs: ${_editPropertyController.docListStrDyn}");

      print(
          "Here is the list of docList URLs: ${_editPropertyController.docPathList}");

      print("Here is the list of docUrls: ${docUrls}");

      var activeController = _editPropertyController.currentController.value;

      print(_editPropertyController.currentController.value);
      if (_editPropertyController.currentController.value
          is ResidentialStepController) {
        if (activeController is! ResidentialStepController) {
          print("Error: Controller mismatch for Residential property type");
          return; // Or handle the error gracefully
        }
        var controller = (_editPropertyController.currentController.value
            as ResidentialStepController);

        print(
            "Controller is: ${_editPropertyController.currentController.value}");
        print("Data is uploading");

        print(controller.property.id);

        print("Property Id is: ${controller.property.id}");

        print("Is furnished is: ${_editPropertyController.furnished.value}");
        print("Currency is: ${controller.currency.value}");

        print(
            "Property option is: ${_editPropertyController.selectedPropertyOption.value}");

        final residentialModel = ResidentialModel(
          id: activeController.property.id,
          agentId: _editPropertyController.userId.value,
          saleOrRent: _editPropertyController.forSaleOrRent.value,
          propertyType: _editPropertyController.selectedPropertyType.value,
          propertyOption: _editPropertyController.selectedPropertyOption.value,
          price: activeController.priceController.value.text,
          description: activeController.descriptionController.value.text,
          amenities: activeController.mAmenities,
          address: _editPropertyController.addressController.value.text,
          city: _editPropertyController.cityController.value.text,
          country: _editPropertyController.countryController.value.text,
          latitude: _editPropertyController.latitude.value,
          longitude: _editPropertyController.longitude.value,
          images: imageUrls,
          documents: docUrls,
          numOfBedrooms: activeController.numOfBedroomsController.value.text,
          numOfBathrooms: activeController.numOfBathroomsController.value.text,
          squareMeters: activeController.squareMetersController.value.text,
          currency: _editPropertyController.currency.value,
          furnished: _editPropertyController.furnished.value,
        );

        print("price is: ${residentialModel.price}");
        try {
          final currentUser = _userRepo.currentUser.value;

          // Fetch favorites from Firestore
          print("Current user type is: ${currentUser!.userType}");
          final firestoreFavorites = await _propertyController.fetchProperties(
              currentUser.userType, currentUser.id);

          bool result =
              await _propertyController.updateProperty(residentialModel);
          print("Result is $result");

          await _userRepo.getProperties();
          print("Retrieved updated properties");

          if (result) {
            // Assuming favoriteProperties is an RxList in your PropertyController
            // _propertyController.favoriteProperties.value = await _propertyController.getFavoriteProperties(firestoreFavorites);
            // No need for setState, as updating the RxList will trigger the UI to update
            await _favoriteController.refreshFavoriteProperties();

            await _propertyController.getProperties();

            _favoriteController.properties.forEach((element) {
              print("Property ppp price is: ${element.price}");
            });
          }
        } catch (e) {
          print("Error in uploading property: $e");
          throw e;
        }
      } else if (_editPropertyController.currentController.value
          is CommercialStepController) {
        var controller = (_editPropertyController.currentController.value
            as CommercialStepController);

        _editPropertyController.currency.value = controller.currency.value;


        print(
            "Controller is: ${_editPropertyController.currentController.value}");
        print("Data is uploading");

        print(controller.property.id);

        print("Property Id is: ${controller.property.id}");

        final commercialModel = CommercialModel(
          id: controller.property.id,
          agentId: _editPropertyController.userId.value,
          saleOrRent: _editPropertyController.forSaleOrRent.value,
          propertyType: _editPropertyController.selectedPropertyType.value,
          propertyOption: _editPropertyController.selectedPropertyOption.value,
          price: controller.priceController.value.text,
          description: controller.descriptionController.value.text,
          amenities: controller.mAmenities,
          address: _editPropertyController.addressController.value.text,
          city: _editPropertyController.cityController.value.text,
          country: _editPropertyController.countryController.value.text,
          latitude: _editPropertyController.latitude.value,
          longitude: _editPropertyController.longitude.value,
          images: imageUrls,
          documents: docUrls,
          squareMeters: controller.squareMetersController.value.text,
          currency: _editPropertyController.currency.value,
          numOfFloors: controller.numFloorsController.value.text,
        );

        print("price is: ${commercialModel.price}");
        try {
          final currentUser = _userRepo.currentUser.value;

          // Fetch favorites from Firestore
          print("Current user type is: ${currentUser!.userType}");
          final firestoreFavorites = await _propertyController.fetchProperties(
              currentUser.userType, currentUser.id);

          bool result = await _propertyController.updateProperty(commercialModel);
          print("Result is $result");

          await _userRepo.getProperties();
          print("Retrieved updated properties");

          if (result) {
            // Assuming favoriteProperties is an RxList in your PropertyController
            // _propertyController.favoriteProperties.value = await _propertyController.getFavoriteProperties(firestoreFavorites);
            // No need for setState, as updating the RxList will trigger the UI to update
            await _favoriteController.refreshFavoriteProperties();

            await _propertyController.getProperties();

            _favoriteController.properties.forEach((element) {
              print("Property ppp price is: ${element.price}");
            });
          }
        } catch (e) {
          print("Error in uploading property: $e");
          throw e;
        }
      } else if (_editPropertyController.currentController.value
          is IndustrialStepController) {
        var controller = (_editPropertyController.currentController.value
            as IndustrialStepController);

        _editPropertyController.currency.value = controller.currency.value;

        print(
            "Controller is: ${_editPropertyController.currentController.value}");
        print("Data is uploading");

        print(controller.property.id);

        print("Property Id is: ${controller.property.id}");

        final industrialModel = IndustrialModel(
          id: controller.property.id,
          agentId: _editPropertyController.userId.value,
          saleOrRent: _editPropertyController.forSaleOrRent.value,
          propertyType: _editPropertyController.selectedPropertyType.value,
          propertyOption: _editPropertyController.selectedPropertyOption.value,
          price: controller.priceController.value.text,
          description: controller.descriptionController.value.text,
          amenities: controller.mAmenities,
          address: _editPropertyController.addressController.value.text,
          city: _editPropertyController.cityController.value.text,
          country: _editPropertyController.countryController.value.text,
          latitude: _editPropertyController.latitude.value,
          longitude: _editPropertyController.longitude.value,
          images: imageUrls,
          documents: docUrls,
          currency: _editPropertyController.currency.value,
          numOfFloors: controller.numFloorsController.value.text,
          totalArea: controller.totalAreaController.value.text,
          areaPerFloor: controller.areaPerFloorController.value.text,
        );

        print("price is: ${industrialModel.price}");
        try {
          final currentUser = _userRepo.currentUser.value;

          // Fetch favorites from Firestore
          print("Current user type is: ${currentUser!.userType}");
          final firestoreFavorites = await _propertyController.fetchProperties(
              currentUser.userType, currentUser.id);

          bool result = await _propertyController.updateProperty(industrialModel);
          print("Result is $result");

          await _userRepo.getProperties();
          print("Retrieved updated properties");

          if (result) {
            // Assuming favoriteProperties is an RxList in your PropertyController
            // _propertyController.favoriteProperties.value = await _propertyController.getFavoriteProperties(firestoreFavorites);
            // No need for setState, as updating the RxList will trigger the UI to update
            await _favoriteController.refreshFavoriteProperties();

            await _propertyController.getProperties();

            _favoriteController.properties.forEach((element) {
              print("Property ppp price is: ${element.price}");
            });
          }
        } catch (e) {
          print("Error in uploading property: $e");
          throw e;
        }
      } else if (_editPropertyController.currentController.value
          is LandStepController) {
        var controller = (_editPropertyController.currentController.value
            as LandStepController);

        _editPropertyController.currency.value = controller.currency.value;

        print(
            "Controller is: ${_editPropertyController.currentController.value}");
        print("Data is uploading");

        print(controller.property.id);

        print("Property Id is: ${controller.property.id}");

        final landModel = LandModel(
          id: controller.property.id,
          agentId: _editPropertyController.userId.value,
          saleOrRent: _editPropertyController.forSaleOrRent.value,
          propertyType: _editPropertyController.selectedPropertyType.value,
          propertyOption: _editPropertyController.selectedPropertyOption.value,
          price: controller.priceController.value.text,
          description: controller.descriptionController.value.text,
          amenities: controller.mAmenities,
          address: _editPropertyController.addressController.value.text,
          city: _editPropertyController.cityController.value.text,
          country: _editPropertyController.countryController.value.text,
          latitude: _editPropertyController.latitude.value,
          longitude: _editPropertyController.longitude.value,
          images: imageUrls,
          documents: docUrls,
          squareMeters: controller.squareMetersController.value.text,
          currency: _editPropertyController.currency.value,
        );

        print("price is: ${landModel.price}");
        try {
          final currentUser = _userRepo.currentUser.value;

          // Fetch favorites from Firestore
          print("Current user type is: ${currentUser!.userType}");
          final firestoreFavorites = await _propertyController.fetchProperties(
              currentUser.userType, currentUser.id);

          bool result = await _propertyController.updateProperty(landModel);
          print("Result is $result");

          await _userRepo.getProperties();
          print("Retrieved updated properties");

          if (result) {
            // Assuming favoriteProperties is an RxList in your PropertyController
            // _propertyController.favoriteProperties.value = await _propertyController.getFavoriteProperties(firestoreFavorites);
            // No need for setState, as updating the RxList will trigger the UI to update
            await _favoriteController.refreshFavoriteProperties();

            await _propertyController.getProperties();

            _favoriteController.properties.forEach((element) {
              print("Property ppp price is: ${element.price}");
            });
          }
        } catch (e) {
          print("Error in uploading property: $e");
          throw e;
        }
      } else {
        Container();
      }
    } on Exception catch (e) {
      print("Error: $e");
    }
  }

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
          "Edit Property",
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
        height: 100.h,
        color: Colors.grey[300],
        child: Stack(
          children: [
            Stepper(
              type: StepperType.horizontal,
              currentStep: currentStep,
              onStepTapped: (step) => setState(() => currentStep = step),
              onStepContinue: () => _handleContinue(),
              onStepCancel: () => _handleCancel(),
              controlsBuilder:
                  (BuildContext context, ControlsDetails controls) {
                return const SizedBox(); // Empty widget
              },
              steps: [
                Step(
                  title: Text('Details'),
                  content: SingleChildScrollView(
                      child: _buildPropertyDetails(widget.property
                          as PropertyModel)), // Cast to specific type
                ),
                Step(
                  title: Text('Location'),
                  content: _buildLocationContent(widget.property
                      as PropertyModel), // Cast to specific type
                ),
                Step(
                  title: Text('Files'),
                  content: _buildMediaContent(widget.property
                      as PropertyModel), // Cast to specific type
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    if (currentStep > 0)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _handleCancel(),
                          child: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey, // Set button color
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  10.0), // Add border radius
                            ),
                            splashFactory: NoSplash
                                .splashFactory, // Apply custom splash color property
                          ),
                        ),
                      ),
                    const SizedBox(width: 12.0), // Spacing between buttons
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleContinue(),
                        child: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Set button color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Add border radius
                          ),
                          splashFactory: NoSplash.splashFactory,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetails(PropertyModel property) {
    // Implement logic to display content based on specific property type properties
    if (property is ResidentialModel) {
      return SingleChildScrollView(
          child: ResidentialDetailsStep(
        property: property,
      ));
    } else if (property is CommercialModel) {
      return CommercialDetailsStep(
        property: property,
      );
    } else if (property is IndustrialModel) {
      return IndustrialDetailsStep(
        property: property,
      );
    } else if (property is LandModel) {
      return LandDetailsStep(
        property: property,
      );
    } else {
      return Container();
    }
  }

  Widget _buildLocationContent(PropertyModel property) {
    // Implement logic to display content based on specific property type properties
    return LocationStep(property: property);
  }

  Widget _buildMediaContent(PropertyModel property) {
    // Implement logic to display content based on specific property type properties
    return ImagesStep(
      property: property,
    );
  }

// ... existing _handleContinue and _handleCancel functions

  void _handleContinue() {
    final currentState = currentStep;
    switch (currentState) {
      case 0:
        // Handle logic for completing step 1 (e.g., validate data, update state)
        setState(() => currentStep += 1);
        break;
      case 1:
        // Handle logic for completing step 2
        setState(() => currentStep += 1);
        break;
      case 2:
        // Handle logic for completing the final step
        // ... process and submit data
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return FutureBuilder(
              future: _uploadData(),
              // Define this method to handle your data upload
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        // This is your loading widget
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
                        Lottie.asset('assets/animation/check.json'),
                        // Replace this with your Lottie animation
                        const SizedBox(height: 10),
                        const Text("Upload completed!"),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
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
        break;
      default:
    }
  }

  void _handleCancel() {
    if (currentStep > 0) {
      setState(() => currentStep -= 1);
    }
  }
}

enum PropertyType { ResidentialModel, commercial, industrial, land }
