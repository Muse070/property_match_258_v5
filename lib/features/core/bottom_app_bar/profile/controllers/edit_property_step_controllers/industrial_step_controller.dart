import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:property_match_258_v5/model/property_models/industrial_property_model.dart';

import '../../../../../../model/property_models/property_model.dart';
import '../../../../../../model/property_models/residential_property_model.dart';

class IndustrialStepController extends GetxController {

  final IndustrialModel property;

  RxString option = RxString('');

  RxList<String> mAmenities = RxList<String>();

  RxString price = RxString('');
  RxString currency = RxString('');
  RxString numFloors = RxString('');
  RxString totalArea = RxString('');
  RxString areaPerFloor = RxString('');
  RxString description = RxString('');

  late Rx<TextEditingController> priceController;
  late Rx<TextEditingController> currencyController;
  late Rx<TextEditingController> numFloorsController;
  late Rx<TextEditingController> totalAreaController;
  late Rx<TextEditingController> areaPerFloorController;
  late Rx<TextEditingController> descriptionController;

  IndustrialStepController(this.property) {
    option.value = property.propertyOption;
    mAmenities.value = property.amenities;
    price.value = property.price;
    currency.value = property.currency;
    numFloors.value = property.numOfFloors;
    totalArea.value = property.totalArea;
    areaPerFloor.value = property.areaPerFloor;
    description.value = property.description;

    priceController = TextEditingController(text: property.price).obs;
    currencyController = TextEditingController(text: property.currency).obs;
    numFloorsController = TextEditingController(text: property.numOfFloors).obs;
    totalAreaController = TextEditingController(text: property.totalArea).obs;
    areaPerFloorController = TextEditingController(text: property.areaPerFloor).obs;
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
    totalAreaController.value.addListener(() {
      totalArea.value = totalAreaController.value.text;
    });
    areaPerFloorController.value.addListener(() {
      areaPerFloor.value = areaPerFloorController.value.text;
    });
    numFloorsController.value.addListener(() {
      numFloors.value = numFloorsController.value.text;
    });
    descriptionController.value.addListener(() {
      description.value = descriptionController.value.text;
    });
  }

  @override
  void dispose() {
    priceController.value.dispose();
    numFloorsController.value.dispose();
    totalAreaController.value.dispose();
    areaPerFloorController.value.dispose();
    descriptionController.value.dispose();
    super.dispose();
  }

  void updatePropertyOption(String option1) {
    option.value = option1;
  }
}
