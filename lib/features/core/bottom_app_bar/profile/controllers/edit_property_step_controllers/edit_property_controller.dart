import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p; // Import the path package
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/commercial_step_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/residential_step_controller.dart';
import 'package:property_match_258_v5/model/property_models/property_model.dart';
import 'package:property_match_258_v5/model/property_models/residential_property_model.dart';

import '../../../../../../model/property_models/commercial_property_model.dart';
import '../../../../../../model/property_models/industrial_property_model.dart';
import '../../../../../../model/property_models/land_property_model.dart';
import 'industrial_step_controller.dart';
import 'land_step_controller.dart';

class EditPropertyController extends GetxController {
  Rx<String> userId = Rx<String>(FirebaseAuth.instance.currentUser!.uid);
  final PropertyModel property;

  late Rx<TextEditingController> currencyController;
  late Rx<TextEditingController> addressController;
  late Rx<TextEditingController> cityController;
  late Rx<TextEditingController> countryController;

  // Media uploads variables
  RxList<Map<String, dynamic>> imageListStrDyn = RxList<Map<String, dynamic>>();

  RxList<Map<String, dynamic>> docListStrDyn = RxList<Map<String, dynamic>>();
  RxList<String> docPathList = RxList<String>();

  final RxList<Map<String, dynamic>> newImages = RxList([]);

  Future<void> initializeMediaLists() async {
    print("Media initialization started");
    // Make it async
    imageListStrDyn.value = property.images.map((imageUrl) {
      // Assuming this is a URL
      return {
        'bytes': imageUrl,
        'extension': '.jpg'
      }; // Adjust extension as needed
    }).toList();

    newImages.addAll(imageListStrDyn);

    print("Image List String Dyn is: ${imageListStrDyn}");

    // Initialize docListStrDyn with bytes and extension for documents
    docListStrDyn.value = property.documents.map((docUrl) {
      return {
        'bytes': docUrl,         // Store the URL directly
        'extension': '.pdf', // Extract extension from URL
      };
    }).toList();

    docPathList.value =
        docListStrDyn.map((doc) => '${doc['bytes']}${doc['extension']}').cast<
            String>().toList();

    print("Doc List String Dyn is: ${docListStrDyn}");


    print("Image and doc initialization complete.");
  }

  EditPropertyController(this.property) {
    getController(property);
    print("Controller retrieved");

    // Load data to variables
    initializeMediaLists();
    print("Media Lists are initialized");
  }

  // Property type index
  RxInt tabIndex = 0.obs;

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

  RxString currency = RxString("");
  RxBool furnished = RxBool(false);

  // Stepper Widget step tracker
  var currentStep = 0.obs;

  RxList<PropertyModel> agentListings = RxList<PropertyModel>([]);

  Rx<GetxController?> currentController = Rx<GetxController?>(null);

  @override
  void onInit() {
    super.onInit();
    initializeVariables(property);
    print("Variables initialized");
  }

  void initializeVariables(PropertyModel property) {
    addressParts.value = property.address;
    city.value = property.city;
    country.value = property.country;
    latitude.value = property.latitude;
    longitude.value = property.longitude;
    forSaleOrRent.value = property.saleOrRent;
    selectedPropertyType.value = property.propertyType;
    selectedPropertyOption.value = property.propertyOption;

    addressController = Rx<TextEditingController>(
        TextEditingController(text: addressParts.value));
    cityController =
        Rx<TextEditingController>(TextEditingController(text: city.value));
    countryController =
        Rx<TextEditingController>(TextEditingController(text: country.value));
  }

  void addLocalImages(List<Map<String, dynamic>> images) {
    for (var image in images) {
      imageListStrDyn.add(image.cast<String, dynamic>()); // <-- Add the cast here
    }
    update();
  }

  // EditPropertyController Class (add this method)
  void updateCurrency(String newCurrency) {
    currency.value = newCurrency; // Update the observable value
    update(); // Notify GetX to rebuild dependent widgets
  }

  void prepareImageList() {
      // Check if 'bytes' is a Base64 string
        imageListStrDyn.value = imageListStrDyn.map((image) {
          if (image['bytes'] is String && isBase64(image['bytes'])) {
            Uint8List decodedBytes = base64Decode(image['bytes']);
            return {'bytes': decodedBytes,};
          } else {
            return image;
          }
        }).toList();

  }

  // Method to preprocess images for display (decoding Base64, handling URLs)
  Future<void> prepareImagesForDisplay() async {
    imageListStrDyn.value = await Future.wait(imageListStrDyn.map((imageData) async {
      if (imageData['bytes'] is Uint8List) {
        // Early return for Uint8List, no need to check for URL
        return {'bytes': imageData['bytes'], 'extension': imageData['extension']};
      }

      String bytesData = imageData['bytes'] as String; // Cast to String since it's not Uint8List

      if (isBase64(bytesData)) {
        Uint8List decodedBytes = base64Decode(bytesData);
        return {'bytes': decodedBytes};
      } else if (isFirebaseStorageUrl(bytesData)) {
        return {'bytes': bytesData};
      } else {
        return {'bytes': null}; // Handle invalid data
      }
    }));
  }


  Future<void> decodeImageListBase64() async {
    print("imageListStrDyn before decoding: ${imageListStrDyn.value}");
    try {
      imageListStrDyn.value = await Future.wait(imageListStrDyn.map((image) async {
        // No need to decode if it's already a URL
        if (image['bytes'] is String && !isFirebaseStorageUrl(image['bytes'])) {
          print("decode started (image)"); // Added to clarify which list is being decoded

          Uint8List decodedBytes = base64Decode(image['bytes']);

 // Add null check
          image = Map.from(image);

          image['bytes'] = decodedBytes;
          print("decoded image bytes: $decodedBytes");
          try {
            print("Base 64 decoded bytes: ${image['bytes']}");
          } on Exception catch (e, stackTrace) {
            print("Error decoding Base64 (image): $e");
            print("Stack Trace: $stackTrace");
          }
        } else {
          print("Skipping decoding (image): Either 'bytes' is not a Base64 string or is a Firebase Storage URL");
          try {
            print("Base 64 decoded bytes: $image");
          } on Exception catch (e, stackTrace) {
            print("Error decoding Base64 (image): $e");
            print("Stack Trace: $stackTrace");
          }
        }
        return image;
      })).then((decodedList) {
        print("Here is imageString AFTER DECODING: $decodedList"); // Now it's updated
        return decodedList;
      });

      print("Here is imageString: $imageListStrDyn");
    } on Exception catch (e, stackTrace) {
      print("Error decoding Base64 (image): $e");
      print("Stack Trace: $stackTrace");
    }

    imageListStrDyn.refresh(); // Ensure UI update if using GetX
  }


  void decodeBase64() {
    print("docListStrDyn is actually: $docListStrDyn");
    try {
      docListStrDyn.value = docListStrDyn.map((doc) {
        // No need to decode if it's already a URL
        // We're assuming the 'bytes' key holds either a Base64 string OR a URL
        if (doc['bytes'] is String && !isFirebaseStorageUrl(doc['bytes'])) {
          print("decode started");
          print("decode base64: ${base64Decode(doc['bytes'])}");

          Uint8List decodedBytes = base64Decode(doc['bytes']);

          print("decode bytes: $decodedBytes");
          doc = Map.from(doc); // If doc is a Map

          try {
            doc['bytes'] = decodedBytes as Uint8List;
          } on Exception catch (e, stackTrace) {
            print("Error decoding Base64: $e");
            print("Stack Trace: $stackTrace");
          }
// Update with decoded bytes
          print("doc['bytes']: ${doc['bytes']}");

          print("decode completed");
        } else {
          print("Skipping decoding: Either 'bytes' is not a Base64 string or is a Firebase Storage URL");
        }
        return doc;
      }).toList();
    } on Exception catch (e, stackTrace) {
      print("Error decoding Base64: $e");
      print("Stack Trace: $stackTrace");
    }
    update();
  }

  // Helper to check if a string is a Firebase Storage URL
  bool isFirebaseStorageUrl(String str) {
    return str.startsWith('https://firebasestorage.googleapis.com/');
  }

  bool isBase64(String str) {
    try {
      base64Decode(str); // Attempt to decode
      return true; // If no error, it's likely Base64
    } catch (e) {
      return false; // If an error occurs, it's not Base64
    }
  }

  void getController(PropertyModel property) {
    if (property is ResidentialModel) {
      currentController.value = ResidentialStepController(property);
      print('Controller is: Residential Step');
    } else if (property is CommercialModel) {
      currentController.value = CommercialStepController(property);
      print('Controller is: Commercial Step');
    } else if (property is IndustrialModel) {
      // Add checks for other property types
      currentController.value = IndustrialStepController(property);
      print('Controller is: Industrial Step');
    } else if (property is LandModel) {
      currentController.value = LandStepController(property);
      print('Controller is: Land Step');
    } else {
      // Handle unsupported property type
      print("Unsupported property type");
    }
  }

  void updateRentOrSale(String option) {
    forSaleOrRent.value = option;
    update();
  }

  void updateMediaLists() {
    imageListStrDyn.addAll(property.images as Iterable<Map<String, dynamic>>);
    docListStrDyn.addAll(property.documents as Iterable<Map<String, dynamic>>);
    update();
  }
}
