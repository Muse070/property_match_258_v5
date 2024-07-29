import 'package:get/get.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/commercial_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/industrial_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/land_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/residential_controllers.dart';
import 'package:property_match_258_v5/model/property_models/property_model.dart';

import '../../../../../../repository/properties_repository/property_repository.dart';

class ListingController extends GetxController {
  // Property type index
  RxInt tabIndex = 0.obs;

  final _propertyController = Get.find<PropertyRepository>();

  var property = PropertyModel(
    id: '',
    agentId: '',
    saleOrRent: '',
    propertyType: '',
    propertyOption: '',
    price: '',
    description: '',
    amenities: [],
    address: '',
    city: '',
    country: '',
    latitude: 0.0,
    longitude: 0.0,
    images: [],
    documents: [],
    currency: '',
  ).obs;

  RxString currency = "USD".obs;

  // Property Location variables
  RxString addressParts = RxString("");
  RxString city = RxString("");
  RxString country = RxString("");
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  // Property details variables
  RxString forSaleOrRent = RxString("");
  RxString selectedPropertyType = RxString("");
  RxString selectedPropertyOption = RxString("");

  // Stepper Widget step tracker
  var currentStep = 0.obs;

  // Media uploads variables
  RxList<Map<String, dynamic>> imageListStrDyn = RxList<Map<String, dynamic>>();

  RxList<Map<String, dynamic>> docListStrDyn = RxList<Map<String, dynamic>>();
  RxList<String> docPathList = RxList<String>();

  RxList<PropertyModel> agentListings = RxList<PropertyModel>([]);

  Rx<GetxController?> currentController = Rx<GetxController?>(null);

  // Property type controller list
  Map<int, GetxController> controllers = {
    0: ResidentialController(),
    1: CommercialController(),
    2: IndustrialController(),
    3: LandController(),
    // Add more controllers as needed
  };

  // ... other controller properties and methods

  @override
  void onInit() {
    super.onInit();
    fetchAgentListings(); // Trigger initial data fetch
  }


  @override
  void dispose() {
    addressParts.value = "";
    city.value = "";
    country.value = "";
    currentController.value?.dispose();
    super.dispose();
  }

  void goTo(int step) {
    currentStep.value = step;
    update();
  }

  void changeTab(int index) {
    // tabIndex.value = index;
    currentController.value = controllers[index];
    print(
        "Tab changed to $index and current controller is: ${currentController.value}");
    update();
  }

  void fetchAgentListings() async {
    final properties = await _propertyController.getCurrentLoggedInAgentsProperties();
    agentListings.value = properties; // Update RxList with fetched data
    print("Agent's properties have been fetched");
  }

  void updateProperty(PropertyModel newProperty) {
    property.value = newProperty;
  }

  void updateSelectedPropertyOption(String option) {
    selectedPropertyOption.value = option;
    print("Updated property option is: $selectedPropertyOption");
    update();
  }

  void updateCurrency(String option) {
    currency.value = option;
    update();
  }

  void updateRentOrSale(String option) {
    forSaleOrRent.value = option;
    update();
  }

  void updateSelectedPropertyType(String option) {
    selectedPropertyType.value = option;
    print("Updated selected property type is: ${selectedPropertyType.value}");
    update();
  }

  void updateLocation(double newLatitude, double newLongitude) {
    latitude.value = newLatitude;
    longitude.value = newLongitude;
    update(); // This will update the UI wherever these variables are being used.
  }

  void updateAddress(String newCountry, String newCity, String newAddress) {
    country.value = newCountry;
    city.value = newCity;
    addressParts.value = newAddress;
    update();
  }

  void reset() {
    // Reset current step
    currentStep.value = 0;

    // reset tabIndex
    tabIndex.value = 0;

    // Reset property Models
    if (currentController.value is ResidentialController) {
      var current = (currentController.value as ResidentialController);
      current.price.value = "";
      current.priceController.value.text = "";
      current.description.value = "";
      current.descriptionController.value.text = "";
      current.squareMeters.value = "";
      current.squareMetersController.value.text = "";
      current.numBathrooms.value = "";
      current.numOfBathroomsController.value.text = "";
      current.numBedrooms.value = "";
      current.numOfBedroomsController.value.text = "";
    } else if (currentController.value is CommercialController) {
      var current = (currentController.value as CommercialController);
      current.cPrice.value = "";
      current.priceController.value.text = "";
      current.cDescription.value = "";
      current.descriptionController.value.text = "";
      current.cSquareMeters.value = "";
      current.squareMetersController.value.text = "";
      current.cNumOfFloors.value = "";
      current.numOfFloorsController.value.text = "";
    } else if (currentController.value is IndustrialController) {
      var current = (currentController.value as IndustrialController);
      current.iPrice.value = "";
      current.priceController.value.text = "";
      current.iDescription.value = "";
      current.descriptionController.value.text = "";
      current.iNumOfFloors.value = "";
      current.numOfFloorsController.value.text = "";
      ;
      current.iAreaPerFloor.value = "";
      current.areaPerFloorController.value.text = "";
      ;
      current.iTotalArea.value = "";
      current.totalAreaController.value.text = "";
    } else if (currentController.value is LandController) {
      var current = (currentController.value as LandController);
      current.lPrice.value = "";
      current.priceController.value.text = "";
      current.lSquareMeters.value = "";
      current.squareMetersController.value.text = "";
      current.descriptionController.value.text = "";
      current.lDescription.value = "";
      current.descriptionController.value.text = "";
    }

    // Reset property details
    forSaleOrRent.value = "";
    selectedPropertyType.value = "";
    selectedPropertyOption.value = "";

    // Reset address and location coordinates
    addressParts.value = "";
    city.value = "";
    country.value = "";
    latitude.value = 0.0;
    longitude.value = 0.0;

    // Reset image list
    imageListStrDyn.clear();

    // Reset doc list
    docListStrDyn.clear();
    docPathList.clear();

    update();
  }
}
