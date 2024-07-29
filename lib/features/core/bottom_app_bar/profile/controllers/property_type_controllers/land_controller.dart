import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LandController extends GetxController {

  RxString option = RxString('');

  RxString lPrice = RxString('');
  RxString lSquareMeters = RxString('');
  RxString lDescription = RxString('');
  RxList<String> lAmenities = RxList<String>();

  Rx<TextEditingController> priceController = TextEditingController.fromValue(
    const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    ),
  ).obs;
  Rx<TextEditingController> squareMetersController = TextEditingController.fromValue(
    const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    ),
  ).obs;
  Rx<TextEditingController> descriptionController = TextEditingController().obs;

  @override
  void onInit() {
    super.onInit();
    priceController.value.addListener(() {
      lPrice.value = priceController.value.text;
    });
    squareMetersController.value.addListener(() {
      lSquareMeters.value = squareMetersController.value.text;
    });
    descriptionController.value.addListener(() {
      lSquareMeters.value = squareMetersController.value.text;
    });
  }

  @override
  void dispose() {
    priceController.value.dispose();
    squareMetersController.value.dispose();
    descriptionController.value.dispose();
    super.dispose();
  }

  void updatePrice(String newText) {
    priceController.value.text = newText;
    lPrice.value = newText;
    update();
  }

  void updateSquareMeters(String newText) {
    squareMetersController.value.text = newText;
    lSquareMeters.value = newText;
    update();
  }

  void updateDescription(String newText) {
    descriptionController.value.text = newText;
    lDescription.value = newText;
    update();
  }

  void updateAmenities(List<String> amenities) {
    lAmenities.assignAll(amenities);
    update();
  }

}