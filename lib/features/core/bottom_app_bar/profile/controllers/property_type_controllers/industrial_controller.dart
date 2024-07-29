import 'package:flutter/cupertino.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class IndustrialController extends GetxController {

  String option = "";

  RxString iPrice = RxString('');
  RxString iNumOfFloors = RxString('');
  RxString iTotalArea = RxString('');
  RxString iAreaPerFloor = RxString('');
  RxString iDescription = RxString('');
  RxList<String> iAmenities = RxList<String>();

  Rx<TextEditingController> priceController = TextEditingController().obs;
  Rx<TextEditingController> numOfFloorsController = TextEditingController().obs;
  Rx<TextEditingController> totalAreaController = TextEditingController().obs;
  Rx<TextEditingController> areaPerFloorController = TextEditingController().obs;
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
    totalAreaController.value.addListener(() {
      update();
    });
    areaPerFloorController.value.addListener(() {
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
    totalAreaController.value.dispose();
    areaPerFloorController.value.dispose();
    descriptionController.value.dispose();
    super.dispose();
  }

  void updatePrice(String newText) {
    priceController.value.text = newText;
    iPrice.value = newText;
    update();
  }

  void updateNumOfFloors(String newText) {
    numOfFloorsController.value.text = newText;
    iNumOfFloors.value = newText;
    update();
  }

  void updateTotalArea(String newText) {
    totalAreaController.value.text = newText;
    iTotalArea.value = newText;
    update();
  }

  void updateAreaPerFloor(String newText) {
    areaPerFloorController.value.text = newText;
    iAreaPerFloor.value = newText;
    update();
  }

  void updateDescription(String newText) {
    descriptionController.value.text = newText;
    iDescription.value = newText;
    update();
  }

  void updateAmenities(List<String> amenities) {
    iAmenities.assignAll(amenities);
    update();
  }

}