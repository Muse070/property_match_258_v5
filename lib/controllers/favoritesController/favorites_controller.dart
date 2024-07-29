import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:property_match_258_v5/controllers/propert_controller/property_controller.dart';
import 'package:property_match_258_v5/model/user_models/agent_model.dart';
import 'package:property_match_258_v5/utils/local_storage.dart';

import '../../model/property_models/property_model.dart';
import '../../repository/user_repository/user_repository.dart';

class FavoriteController extends GetxController {
  static FavoriteController get instance => Get.find();

  final _userRepo = Get.find<UserRepository>();
  final _propertyController = Get.find<PropertyController>();

  final favorites = <String, bool>{}.obs;
  final firestoreUser = FirebaseAuth.instance.currentUser;

  RxList<PropertyModel> properties = RxList([]);
  var isLoading = true.obs;



  @override
  void onInit() {
    super.onInit();
    _userRepo.currentUser.listen((user) {
      if (user != null  && user.userType.isNotEmpty) {
        initFavorites();
      }
    });
  }

  Future<void> initFavorites() async {
    final currentUser = _userRepo.currentUser.value;

    // Fetch favorites from Firestore
    print("Current user type is: ${currentUser!.userType}");
    final firestoreFavorites = await _propertyController
        .fetchProperties(currentUser.userType, currentUser.id);
    print("Firestore favorites are: $firestoreFavorites");

    // If Firestore favorites are not empty, update local storage
    if (firestoreFavorites.isNotEmpty) {
      favorites.assignAll({ for (var item in firestoreFavorites) item : true });
      saveFavoritesToStorage();
    } else {
      // If Firestore favorites are empty, clear local storage
      print("No favorites found in Firestore for this user.");
      TLocalStorage.instance().removeData('favorites');
      favorites.clear();
    }

    // Save favorites to Firestore
    saveFavoritesToFirestore();

    // Get the updated list of favorite properties
    List<PropertyModel> updatedFavorites = await favoriteProperties();

    // Clear the properties list and add the updated favorites
    properties.clear();
    properties.addAll(updatedFavorites);
    print("Favorites from controller are: $properties");
    isLoading.value = false;
    update();
  }

  // Call this method after a property has been successfully updated
// This method refreshes the favorite properties list
  Future<void> refreshFavoriteProperties() async {
    isLoading.value = true;

    // Assuming userRepo has a list of all properties
    List<PropertyModel> allProperties = _userRepo.properties;

    // Filter the properties based on the user's favorites
    List<PropertyModel> updatedFavorites = allProperties
        .where((property) => isFavorite(property.id))
        .toList();

    // Update the properties list with the new data
    properties.value = updatedFavorites;

    isLoading.value = false;
    update(); // Notify the listeners about the update
  }

  bool isFavorite(String productId) {
    return favorites[productId] ?? false;
  }

  Future<void> toggleFavoriteProduct(String productId) async {
    final user = _userRepo.currentUser.value;
    if(!favorites.containsKey(productId)){
      favorites[productId] = true;
    } else {
      favorites.remove(productId);
    }
    saveFavoritesToStorage();
    saveFavoritesToFirestore();

    // Get the updated list of favorite properties
    List<PropertyModel> updatedFavorites = await favoriteProperties();

    // Clear the properties list and add the updated favorites
    properties.clear();
    properties.addAll(updatedFavorites);
    print("Favorite Properties are: $properties");

    favorites.refresh();
    displayFavorites();
    update();
  }

  void saveFavoritesToStorage() {
    final encodedFavorites = json.encode(favorites);
    TLocalStorage.instance().saveData('favorites', encodedFavorites);
  }

  void saveFavoritesToFirestore() async {
    final storedFavorites = TLocalStorage.instance().readData<String>('favorites');
    if (storedFavorites != null) {
      final favoritesMap = json.decode(storedFavorites) as Map<String, dynamic>;
      final favorites = favoritesMap.keys.toList();
      await _propertyController.saveFavoriteProperties(
        favorites,
        _userRepo.currentUser.value!.userType,
        _userRepo.currentUser.value!.id,

      );
    }
  }

  Future<List<PropertyModel>> favoriteProperties() async {
    final favoritePropertyIds = favorites.keys.toList();
    // Call a method from PropertyController to fetch properties by ID
    final updatedProperties = await _propertyController.getFavoriteProperties(favoritePropertyIds);

    return updatedProperties;
  }

  void displayFavorites() {
    final storedFavorites = TLocalStorage.instance().readData<String>('favorites');
    if (storedFavorites != null) {
      final favoritesMap = json.decode(storedFavorites) as Map<String, dynamic>;
      print('Favorite Products:');
      favoritesMap.forEach((productId, isFavorite) {
        if (isFavorite) {
          print(productId);
        }
      });
    } else {
      print('No favorite products found.');
    }
  }

  Future<void> deleteAllFavorites() async {
    try {
      // Clear local storage
      TLocalStorage.instance().removeData('favorites');
      favorites.clear();

      // Save the empty favorites to Firestore
      saveFavoritesToFirestore();

      // Get an empty list of favorite properties (optional)
      List<PropertyModel> updatedFavorites = [];

      // Clear the properties list and add the empty list (optional)
      properties.clear();
      properties.addAll(updatedFavorites);

      favorites.refresh();
      update();
    } catch (error) {
      // Handle potential errors during Firestore saving
      print("Error saving to Firestore: $error");
    }
  }

}