import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:property_match_258_v5/controllers/favoritesController/favorites_controller.dart';
import 'package:property_match_258_v5/model/user_models/agent_model.dart';
import 'package:property_match_258_v5/model/user_models/client_model.dart';
import 'package:property_match_258_v5/model/user_models/user_model.dart';
import 'package:property_match_258_v5/repository/authentication_repository/authentication_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/agent_repository.dart';


import '../../controllers/propert_controller/property_controller.dart';
import '../../model/property_models/property_model.dart';
import '../../utils/local_storage.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _auth = Get.find<AuthenticationRepository>();
  final _propertyController = Get.find<PropertyController>();
  // final _agentRepo = Get.find<AgentRepository>();

  RxString currentAddress = "".obs;
  RxList<PropertyModel> properties = <PropertyModel>[].obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  LatLng currentPosition = const LatLng(0.0, 0.0);

  Rx<UserModel?> currentUser = Rx<UserModel?>(
    UserModel(
      email: "",
      userType: "",
      lastName: "",
      phoneNo: "",
      password: "",
      id: "",
      firstName: "",
      imageUrl: "",
      address: '',
      city: '',
      country: '',
      propertyIds: [],
    ),
  );

  Rx<ClientModel?> clientModel = Rx<ClientModel?>(
      ClientModel(
        email: "",
        userType: "",
        lastName: "",
        phoneNo: "",
        password: "",
        id: "",
        firstName: "",
        address: "",
        city: "",
        country: "",
        preferences: "",
        imageUrl: "",
      )
  );

  @override
  void onInit() {
    super.onInit();
    checkLoggedInUser();
  }


  Future<Position> getLocation() async {
    await Geolocator.requestPermission().then((value) async {

    }).onError((error, stackTrace){
      print('Error: $error');
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks[0];

      // Format the address using the Placemark fields.
      String address = '${place.name}, ${place.locality}, ${place.country}';
      return address;
    } on Exception catch (e) {
      print("Error getting location: $e");
      return '';
    }
  }

  Future<void> getProperties() async {
    properties.value = await _propertyController.getProperties();
    print(properties.value);
    print("Properties have been refreshed");
  }

  Future<void> refreshProperties() async {
    try {
      final email = currentUser.value?.email;
      if (email != null) {
        await getProperties();
        print("Successfully Refreshed");
      } else {
        // Handle the case where email is null
        print("Error: User email is null");
      }
    } catch (e) {
      print("Error during refresh: $e");
      // Handle the error appropriately (e.g., show a snackbar)
    }
  }

  Future<void> updateClientDetails(ClientModel updatedClient) async {
    print("Updated agent Id is:  ${updatedClient.id}");

    try {
      await _firestore.collection('clients').doc(updatedClient.id).update({
        'FirstName': updatedClient.firstName,
        'LastName': updatedClient.lastName,
        'Email': updatedClient.email,
        'PhoneNumber': updatedClient.phoneNo,
        'UserType': updatedClient.userType,
        'Id': updatedClient.id,
        'Address': updatedClient.address,
        'City': updatedClient.city,
        'Country': updatedClient.country,
        'Preferences': updatedClient.preferences,
        'Password': updatedClient.password,
        'ImageUrl': updatedClient.imageUrl,
      });

      // Update the client in the repository (to keep it in sync with Firestore)
      clientModel.value = updatedClient;
      update(); // Trigger a UI update if needed
    } catch (e) {
      print('Error updating agent details: $e');
      // Handle the error (e.g., show a snackbar to the user)
      rethrow; // Re-throw the exception for handling in the UI layer
    }
  }

  Future<void> getUserDetails(String email) async {
    try {
      var snapshot = await _db.collection("clients").where("Email", isEqualTo: email).get();
      if (snapshot.docs.isEmpty) {
        snapshot = await _db.collection("agents").where("Email", isEqualTo: email).get();
      }

      if (snapshot.docs.isEmpty) {
        print("User data is empty !!!!!");
      } else if (snapshot.docs.length > 1) {
        print("Error: Multiple users with the same email");
      } else {

        final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;
        currentUser.value = userData;

        if (userData.userType == 'client') {
          // Set the clientModel using your getClient function
          print("User type is of client");
          clientModel.value = await getClient(userData.id); // Fetch the client details
          print("Client model has been initialized");
          print("Client model is: ${clientModel.value}");
        }


        print("Favorite controller initialization started");
        Get.put(FavoriteController());

        print("Local storage initialization started.");
        await TLocalStorage.init(currentUser.value!.id);

        final position = await getLocation();
        currentPosition = LatLng(position.latitude, position.longitude);

        currentAddress.value = await getAddressFromLatLng(position.latitude, position.longitude);

        print("Position is ${position.latitude}, ${position.longitude}");
        print("Current position is ${currentPosition.latitude}, ${currentPosition.longitude}");


        if (kDebugMode) {
          print("${userData.firstName} + " " + ${userData.lastName}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error for getting user data: $e');
      }
      rethrow;
    }
  }

  Future<ClientModel> getClient(String clientId) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('clients').doc(clientId).get();
      return ClientModel.fromSnapshot(userDoc);
    } on Exception catch (e) {
      print("Failed to get clients: $e");
      rethrow;
    }
  }

  checkLoggedInUser() {
    print("_checkLoggedInUser is active");
    _auth.firebaseUser.listen((User? user) async {
      print(user);
      if (user != null) {
        await getUserDetails(user.email!);
        await getProperties();
      } else {
        if (kDebugMode) {
          print("User has a null value");
        }
        // Don't try to navigate if the user is null
        if (Get.currentRoute != '/') {
          Get.offAllNamed('/');
        }
      }
    });
  }


  Future<bool> createUser(UserModel user, String modelType) async {
    final CollectionReference usersRef =
    _db.collection(modelType);
    print("Entering create user method !!!!!!");
    try {
      await usersRef.doc(user.id).set(user.toJson()); // Use the user's ID as the document ID
      // doc(user.id).set(user.toJson());
      print("User Your account has been created.");

      Get.snackbar("Success", "Your account has been created.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green);
      return true;
    } catch (error, stackTrace) {
      Get.snackbar("Error", 'Failed to create account. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.redAccent);
      if (kDebugMode) {
        print('Error creating user: $stackTrace');
      }
      return false;
    }
  }

  Future<List<UserModel>> allClients() async {
    final snapshot = await _db.collection("clients").get();
    final userData =
    snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    return userData;
  }

  Future<List<UserModel>> allAgents() async {
    final snapshot = await _db.collection("agents").get();
    final userData =
    snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    return userData;
  }

  Future<void> updateClientRecord(UserModel user) async {
    await _db.collection("clients").doc(user.id).update(user.toJson());
  }

  Future<void> updateAgentRecord(UserModel user) async {
    await _db.collection("agents").doc(user.id).update(user.toJson());
  }

  Future<void> updateUser(UserModel user, String modelType) async {
    try {
      // Get the currently logged in user.
      User? firebaseUser = _auth.currentUser;

      // Check if a user is logged in.
      if (firebaseUser != null) {
        // Update the user document in Firestore.
        await _db.collection(modelType).doc(firebaseUser.uid).set(user.toJson());
      } else {
        if (kDebugMode) {
          print('No user is logged in.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user: $e');
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out the user from the user repository
      await _auth.logout();
      // Clear the user data in the controller
      currentUser = Rx<UserModel?>(
        UserModel(
          email: "",
          userType: "",
          lastName: "",
          phoneNo: "",
          password: "",
          id: "",
          firstName: "",
          imageUrl: "",
          address: '',
          city: '',
          country: '',
        ),
      );
      // Notify the UI that the user data has changed
      update();
    } catch (error) {
      // Handle the error
      print(error);
    }
  }
}
