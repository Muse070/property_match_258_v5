import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../../../model/property_models/commercial_property_model.dart';
import '../../../../../../model/property_models/property_model.dart';
import '../../../../../../model/property_models/residential_property_model.dart';

class CommercialStepController extends GetxController {

  final CommercialModel property;

  RxString option = RxString('');

  RxList<String> mAmenities = RxList<String>();

  RxString price = RxString('');
  RxString currency = RxString('');
  RxString numFloors = RxString('');
  RxString squareMeters = RxString('');
  RxString description = RxString('');

  late Rx<TextEditingController> priceController;
  late Rx<TextEditingController> currencyController;
  late Rx<TextEditingController> numFloorsController;
  late Rx<TextEditingController> squareMetersController;
  late Rx<TextEditingController> descriptionController;

  CommercialStepController(this.property) {
    option.value = property.propertyOption;
    mAmenities.value = property.amenities;
    price.value = property.price;
    currency.value = property.currency;
    numFloors.value = property.numOfFloors;
    squareMeters.value = property.squareMeters;
    description.value = property.description;

    priceController = TextEditingController(text: property.price).obs;
    currencyController = TextEditingController(text: property.currency).obs;
    numFloorsController = TextEditingController(text: property.numOfFloors).obs;
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
    priceController.value.addListener(() {
      currency.value = currencyController.value.text;
    });
    numFloorsController.value.addListener(() {
      numFloors.value = numFloorsController.value.text;
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
    numFloorsController.value.dispose();
    squareMetersController.value.dispose();
    descriptionController.value.dispose();
    super.dispose();
  }

  void updatePropertyOption(String option1) {
    option.value = option1;
  }
}
