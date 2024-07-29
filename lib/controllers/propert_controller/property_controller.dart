import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_match_258_v5/model/user_models/agent_model.dart';
import 'package:property_match_258_v5/repository/properties_repository/property_repository.dart';

import '../../model/property_models/property_model.dart';
import '../../repository/authentication_repository/authentication_repository.dart';

class PropertyController extends GetxController {
  static PropertyController get instance => Get.find();

  final PropertyRepository _propertyRepository = Get.find<PropertyRepository>();
  final AuthenticationRepository _authenticationRepository = Get.find<AuthenticationRepository>();

  RxList<PropertyModel> favoriteProperties = <PropertyModel>[].obs;
  final properties = <PropertyModel>[].obs; // Observables property list

  Future<bool> addProperty(PropertyModel property,) async {
    var id = _authenticationRepository.currentUser?.uid;
    print("Property: $property");
    print("Id: $id");
    return await _propertyRepository.addProperty(property, id!);
  }

  Future<List<PropertyModel>> getFavoriteProperties(List<String> propertyIds) async {
    favoriteProperties.value = await _propertyRepository.getFavoriteProperties(propertyIds);
    return favoriteProperties;
  }

  Future<List<String>> fetchProperties(String userType, String userId) async {
    var user = "";
    if (userType == "agent") {
      user = "agents";
    } else {
      user = "clients";
    }
    return await _propertyRepository.fetchFavoriteProperties(user, userId);
  }

  Future<void> saveFavoriteProperties(List<String> properties, String userType, String userId) async {
    var user = "";
    if (userType == "agent") {
      user = "agents";
    } else {
      user = "clients";
    }
    return _propertyRepository.saveFavoriteProperties(properties, user, userId);
  }

  Future<List<PropertyModel>> getProperties() async {
    return await _propertyRepository.getProperties();
  }

  Future<AgentModel> getAgentDetailsForProperty(String agentId) {
    return _propertyRepository.getAgentDetails(agentId);
  }

  Future<void> getAllProperties() async {
    try {
      List<PropertyModel> propertyList = await _propertyRepository.getProperties();
      properties.assignAll(propertyList); // Update the observable list
    } catch (e) {
      // Handle errors here
      print("Error fetching properties: $e");
    }
  }


  Future<bool> updateProperty(property) async {
    print("Started print");
    return _propertyRepository.updateProperty(property);
  }

  Future<bool> deleteProperty(String id) async {
    return _propertyRepository.deleteProperty(id);
  }

  Future<List<String>> uploadImageListToStorage(List<Map<String, dynamic>> files) async {
    try {
      print("I start here");
      String path = "propertyImages/";
      List<String> result = await _propertyRepository.uploadFilesToStorage(files, path);
      print("Upload image list to storage is: $result");
      return result;
    } catch (e) {
      print('Error in uploadImageListToStorage: $e');
      throw e; // rethrow the exception to be handled by the caller
    }
  }

  Future<List<String>> uploadDocListToStorage(List<Map<String, dynamic>> files) async {
    try {
      String path = "propertyDocuments/";
      List<String> result = await _propertyRepository.uploadFilesToStorage(
          files, path);
      print("Printed doc list is: $result");
      return result;
    } catch (e){
      print('Error in uploadDocListToStorage: $e');
      throw e;
    }
  }

}