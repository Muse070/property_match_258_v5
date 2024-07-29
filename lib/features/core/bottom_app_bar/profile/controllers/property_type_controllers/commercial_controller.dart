import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class CommercialController extends GetxController {

  RxString option = "".obs;

  RxString cPrice = RxString("");
  RxString cNumOfFloors = RxString("");
  RxString cSquareMeters = RxString("");
  RxString cDescription = RxString("");
  RxList<String> cAmenities = RxList<String>();

  Rx<TextEditingController> priceController = TextEditingController().obs;
  Rx<TextEditingController> numOfFloorsController = TextEditingController().obs;
  Rx<TextEditingController> squareMetersController = TextEditingController().obs;
  Rx<TextEditingController> descriptionController = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    priceController.value.addListener(() {
      update();
    });
    numOfFloorsController.value.addListener(() {
      update();
    });
    squareMetersController.value.addListener(() {
      update();
    });
    descriptionController.value.addListener(() {
      update();
    });
  }

  @override
  void dispose() {
    priceController.value.dispose();
    numOfFloorsController.value.dispose();
    squareMetersController.value.dispose();
    descriptionController.value.dispose();
    super.dispose();
  }

  void updatePrice(String newText) {
    priceController.value.text = newText;
    cPrice.value = newText;
    update();
  }

  void updateNumOfFloors(String newText) {
    numOfFloorsController.value.text = newText;
    cNumOfFloors.value = newText;
    update();
  }

  void updateSquareMeters(String newText) {
    squareMetersController.value.text = newText;
    cSquareMeters.value = newText;
    update();
  }

  void updateDescription(String newText) {
    descriptionController.value.text = newText;
    cDescription.value = newText;
    update();
  }

  void updateAmenities(List<String> amenities) {
    cAmenities.assignAll(amenities);
    update();
  }
}