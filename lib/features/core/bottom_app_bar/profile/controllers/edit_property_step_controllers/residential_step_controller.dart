import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/edit_property_controller.dart';

import '../../../../../../model/property_models/property_model.dart';
import '../../../../../../model/property_models/residential_property_model.dart';

class ResidentialStepController extends GetxController {

  final ResidentialModel property;

  RxString propertyOption = ''.obs;


  RxList<String> mAmenities = RxList<String>();

  RxString price = RxString('');
  RxString currency = RxString('');
  RxString numBathrooms = RxString('');
  RxString numBedrooms = RxString('');
  RxString squareMeters = RxString('');
  RxString description = RxString('');

  RxBool isFurnished = false.obs;

  late Rx<TextEditingController> priceController;
  late Rx<TextEditingController> currencyController;
  late Rx<TextEditingController> optionController;
  late Rx<TextEditingController> numOfBathroomsController;
  late Rx<TextEditingController> numOfBedroomsController;
  late Rx<TextEditingController> squareMetersController;
  late Rx<TextEditingController> descriptionController;

  ResidentialStepController(this.property) {
    propertyOption.value = property.propertyOption;
    mAmenities.value = property.amenities;
    price.value = property.price;
    currency.value = property.currency;
    numBathrooms.value = property.numOfBathrooms;
    numBedrooms.value = property.numOfBedrooms;
    squareMeters.value = property.squareMeters;
    description.value = property.description;
    isFurnished.value = property.furnished;

    priceController = TextEditingController(text: property.price).obs;
    currencyController = TextEditingController(text: property.currency).obs;
    optionController = TextEditingController(text: property.propertyOption).obs;
    numOfBathroomsController = TextEditingController(text: property.numOfBathrooms).obs;
    numOfBedroomsController = TextEditingController(text: property.numOfBedrooms).obs;
    squareMetersController = TextEditingController(text: property.squareMeters).obs;
    descriptionController = TextEditingController(text: property.description).obs;
    print("Residential controllers are initialized");


  }


  @override
  void onInit() {
    super.onInit();
    priceController.value.addListener(() {
      price.value = priceController.value.text;
    });
    currencyController.value.addListener(() {
      currency.value = currencyController.value.text;
    });
    numOfBedroomsController.value.addListener(() {
      numBedrooms.value = numOfBedroomsController.value.text;
    });
    numOfBathroomsController.value.addListener(() {
      numBathrooms.value = numOfBathroomsController.value.text;
    });
    squareMetersController.value.addListener(() {
      squareMeters.value = squareMetersController.value.text;
    });
    descriptionController.value.addListener(() {
      description.value = descriptionController.value.text;
    });
  }

  @override
  void dispose() {
    priceController.value.dispose();
    currencyController.value.dispose();
    numOfBedroomsController.value.dispose();
    numOfBathroomsController.value.dispose();
    squareMetersController.value.dispose();
    descriptionController.value.dispose();
    super.dispose();
  }

  void updateAmenities(List<String> selectedAmenities) {
    mAmenities.value = selectedAmenities;
  }

  void updatePropertyOption(String option) {
    propertyOption.value = option;
  }

  void updateCurrency(String curr) {
    if (currency.value != curr ) {
      currency.value = curr;
      currencyController.value.text = curr;
    }
  }

}
