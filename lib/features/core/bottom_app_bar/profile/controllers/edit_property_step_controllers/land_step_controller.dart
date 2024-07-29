import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:property_match_258_v5/model/property_models/land_property_model.dart';

class LandStepController extends GetxController {
  final LandModel property;

  RxString option = RxString('');

  RxList<String> mAmenities = RxList<String>();

  RxString price = RxString('');
  RxString currency = RxString('');
  RxString squareMeters = RxString('');
  RxString description = RxString('');

  late Rx<TextEditingController> priceController;
  late Rx<TextEditingController> currencyController;
  late Rx<TextEditingController> squareMetersController;
  late Rx<TextEditingController> descriptionController;

  LandStepController(this.property) {
    price.value = property.price;
    currency.value = property.currency;
    squareMeters.value = property.squareMeters;
    description.value = property.description;

    priceController = TextEditingController(text: property.price).obs;
    currencyController = TextEditingController(text: property.currency).obs;
    squareMetersController =
        TextEditingController(text: property.squareMeters).obs;
    descriptionController =
        TextEditingController(text: property.description).obs;
    print("Land controllers are initialized");
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
    squareMetersController.value.dispose();
    descriptionController.value.dispose();
    super.dispose();
  }

  void updatePropertyOption(String option1) {
    option.value = option1;
    update();
  }
}
