import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ResidentialController extends GetxController {

  RxString option = RxString('');

  RxList<String> mAmenities = RxList<String>();

  RxBool isFurnished = false.obs;
  RxString price = RxString('');
  RxString numBathrooms = RxString('');
  RxString numBedrooms = RxString('');
  RxString squareMeters = RxString('');
  RxString description = RxString('');

  Rx<TextEditingController> priceController = TextEditingController().obs;
  Rx<TextEditingController> numOfBathroomsController = TextEditingController().obs;
  Rx<TextEditingController> numOfBedroomsController = TextEditingController().obs;
  Rx<TextEditingController> squareMetersController = TextEditingController().obs;
  Rx<TextEditingController> descriptionController = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    priceController.value.addListener(() {
      price.value = priceController.value.text;
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
    numOfBedroomsController.value.dispose();
    numOfBathroomsController.value.dispose();
    squareMetersController.value.dispose();
    descriptionController.value.dispose();
    super.dispose();
  }

  void updatePrice(String newText) {
    priceController.value.text = newText;
    price.value = newText;
    update();
  }

  void updateNumOfBedrooms(String newText) {
    numOfBedroomsController.value.text = newText;
    numBedrooms.value = newText;
    update();
  }

  void updateNumOfBathrooms(String newText) {
    numOfBathroomsController.value.text = newText;
    numBathrooms.value = newText;
    update();
  }

  void updateSquareMeters(String newText) {
    squareMetersController.value.text = newText;
    squareMeters.value = newText;
    update();
  }

  void updateDescription(String newText) {
    descriptionController.value.text = newText;
    description.value = newText;
    update();
  }

  void updateAmenities(List<String> amenities) {
    mAmenities.assignAll(amenities);
    update();
  }
}