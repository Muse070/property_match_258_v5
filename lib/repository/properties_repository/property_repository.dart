import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:property_match_258_v5/model/user_models/agent_model.dart';
import '../../controllers/propert_controller/property_controller.dart';
import '../../model/property_models/commercial_property_model.dart';
import '../../model/property_models/industrial_property_model.dart';
import '../../model/property_models/land_property_model.dart';
import '../../model/property_models/property_model.dart';
import '../../model/property_models/residential_property_model.dart';

class PropertyRepository extends GetxController {
  static PropertyController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  RxList<PropertyModel> properties = RxList<PropertyModel>();

  Future<bool> addProperty(PropertyModel property, String userId) async {
    try {
      var json = property.toJson();
      print(json.runtimeType);
      DocumentReference propertyRef = await
      _firestore.collection('properties').add(property.toJson());
      await _firestore.collection('agents').doc(userId).update({
        'propertyIds': FieldValue.arrayUnion([propertyRef.id])
      });
      return true;
    } catch (e) {
      print("Firebase exception is false:  ${e.toString()}");
      return false;
    }
  }


  Future<List<PropertyModel>> getCurrentLoggedInAgentsProperties() async {
    if (currentUser?.uid == null) {
      return []; // Handle case when no user is logged in
    }

    try {
      // Fetch agent document to get property IDs
      final DocumentSnapshot agentDoc = await _firestore.collection('agents')
          .doc(currentUser?.uid)
          .get();
      if (!agentDoc.exists) {
        return []; // Handle case where agent document doesn't exist
      }

      final List<String> propertyIds = List<String>.from(
          agentDoc['PropertyIds'] ?? []);

      // Fetch properties based on retrieved IDs
      final List<PropertyModel> properties = [];
      for (String id in propertyIds) {
        final DocumentSnapshot propertyDoc = await _firestore.collection(
            'properties').doc(id).get();
        if (propertyDoc.exists) {
          switch (propertyDoc['PropertyType']) {
            case 'Residential':
              properties.add(ResidentialModel.fromSnapshot(propertyDoc));
              break;
            case 'Industrial':
              properties.add(IndustrialModel.fromSnapshot(propertyDoc));
              break;
            case 'Commercial':
              properties.add(CommercialModel.fromSnapshot(propertyDoc));
              break;
            case 'Land':
              properties.add(LandModel.fromSnapshot(propertyDoc));
              break;
            default:
              throw Exception('Unknown property type');
          }
        }
      }
      return properties;
    } on Exception catch (e) {
      print(e.toString());
      return [];
    }
  }


  Future<List<PropertyModel>> getFavoriteProperties(
      List<String> propertyIds) async {
    try {
      List<PropertyModel> favoriteProperties = [];
      for (String id in propertyIds) {
        DocumentSnapshot doc = await _firestore.collection('properties')
            .doc(id)
            .get();
        switch (doc['PropertyType']) {
          case 'Residential':
            favoriteProperties.add(ResidentialModel.fromSnapshot(doc));
            break;
          case 'Industrial':
            favoriteProperties.add(IndustrialModel.fromSnapshot(doc));
            break;
          case 'Commercial':
            favoriteProperties.add(CommercialModel.fromSnapshot(doc));
            break;
          case 'Land':
            favoriteProperties.add(LandModel.fromSnapshot(doc));
            break;
          default:
            throw Exception('Unknown property type');
        }
      }
      return favoriteProperties;
    } on Exception catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<List<String>> fetchFavoriteProperties(String userType,
      String userId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection(userType).doc(
          userId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['FavoriteProperties'] ?? []);
      }
    } on Exception catch (e) {
      print("Error: $e");
    }
    return [];
  }

  Future<void> saveFavoriteProperties(List<String> properties, String userType,
      String userId) async {
    try {
      DocumentReference docRef = _firestore.collection(userType).doc(userId);
      await docRef.update({
        'FavoriteProperties': properties,
      });
    } on Exception catch (e) {
      print("Error: $e");
    }
  }

  Future<PropertyModel> getProperty(String propertyId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('properties').doc(
          propertyId).get();
      if (snapshot.exists) {
        switch (snapshot['PropertyType']) {
          case 'Residential':
            return ResidentialModel.fromSnapshot(snapshot);
          case 'Industrial':
            return IndustrialModel.fromSnapshot(snapshot);
          case 'Commercial':
            return CommercialModel.fromSnapshot(snapshot);
          case 'Land':
            return LandModel.fromSnapshot(snapshot);
          default:
            throw Exception('Unknown property type');
        }
      } else {
        throw Exception('Property not found');
      }
    } on Exception catch (e) {
      print(e.toString());
      throw e; // Rethrow the exception for higher-level handling
    }
  }


  Future<List<PropertyModel>> getProperties() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('properties').get();
      return snapshot.docs.map((doc) {
        switch (doc['PropertyType']) {
          case 'Residential':
            return ResidentialModel.fromSnapshot(doc);
          case 'Industrial':
            return IndustrialModel.fromSnapshot(doc);
          case 'Commercial':
            return CommercialModel.fromSnapshot(doc);
          case 'Land':
            return LandModel.fromSnapshot(doc);
          default:
            throw Exception('Unknown property type');
        }
      }).toList();
    } on Exception catch (e) {
      print(e.toString());
      return [];
    }
  }

  Future<AgentModel> getAgentDetails(String agentId) async {
    DocumentSnapshot snapshot = await _firestore.collection('agents').doc(
        agentId).get();
    return AgentModel.fromSnapshot(snapshot);
  }

  Future<bool> updateProperty(PropertyModel property) async {
    print("Property id is: ${property.id}");
    var json = property.toJson();
    try {
      print("Json runtime: ${json.runtimeType}");
      await _firestore.collection('properties').doc(property.id).update(json);
      print("Property is: ${property.toJson()}");
      print("Property successfully updated to: ${property.id}");
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteProperty(String id) async {
    try {
      await _firestore.collection('properties').doc(id).delete();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }


  Future<List<String>> uploadFilesToStorage(List<Map<String, dynamic>> files, String path) async {
    try {
      List<String> urls = [];

      for (var file in files) {
        dynamic fileData = file['bytes'];
        String extension = file['extension'] ?? ''; // Get extension if available, otherwise use default empty string

        // Check if extension needs to be determined from the file content
        if (extension.isEmpty && fileData is Uint8List) {
          String? mimeType = lookupMimeType('', headerBytes: fileData);
          if (mimeType != null) {
            extension = p.extension('file.$mimeType');
            print("File extension is: $extension");
          } else {
            print('Error: Could not determine file extension for file: $file');
            continue; // Skip to the next file if extension cannot be determined
          }
        }

        if (fileData is Uint8List) {
          // Upload new file
          String storagePath = '$path/${DateTime.now().millisecondsSinceEpoch}$extension';
          firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref(storagePath);
          await ref.putData(fileData);
          fileData = await ref.getDownloadURL() + extension; // Append extension
        } else if (fileData is String) {
          // Assuming fileData is already a URL with the correct extension
        } else {
          print("Invalid file data type: ${fileData.runtimeType}");
          continue; // Skip unsupported types
        }

        urls.add(fileData.toString());
        print("Crucial* Urls are: $urls");
      }

      return urls;
    } catch (e) {
      print('Error in uploadFilesToStorage: $e');
      throw e;
    }
  }

  String? _getExtension(dynamic fileData) {
    if (fileData is Uint8List) {
      // For Uint8List, you might need to inspect the file's header bytes to determine the type.
      // This can be complex, so for now, we'll return null (no extension found).
      return null;
    } else if (fileData is String) {
      try {
        Uri uri = Uri.parse(fileData);
        String path = uri.path;
        int lastDotIndex = path.lastIndexOf('.');
        return lastDotIndex != -1 ? path.substring(lastDotIndex) : null;
      } catch (e) {
        return null; // Error parsing URL
      }
    } else {
      return null; // Unsupported type
    }
  }




  Future<Uint8List> _readFile(String filePath) async {
    File file = File(filePath);
    Uint8List bytes = await file.readAsBytes();
    return bytes;
  }

  Future<Uint8List> _downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load file');
    }
  }


}