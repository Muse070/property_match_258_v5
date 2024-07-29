import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:property_match_258_v5/model/user_models/user_model.dart';

class ClientModel extends UserModel {
  List<String>? savedProperties;
  List<String>? favoriteAgents;
  String? preferences;

  ClientModel({
    required super.email,
    required super.userType,
    required super.lastName,
    required super.phoneNo,
    required super.password,
    required super.id,
    required super.firstName,
    required super.address,
    required super.city,
    required super.country,
    this.preferences,
    super.imageUrl,
    super.propertyIds,
    super.favoriteProperties,
    this.favoriteAgents,
    this.savedProperties,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();
    map["SavedProperties"] = savedProperties;
    map["FavoriteAgents"] = favoriteAgents;
    map["Preferences"] = preferences;
    return map;
  }

  factory ClientModel.fromSnapshot(DocumentSnapshot<Object?> document) {
    try {
      final data = document.data() as Map<String, dynamic>;
      return ClientModel(
        email: data["Email"] ?? '',
        userType: data["UserType"] ?? '',
        lastName: data["LastName"] ?? '',
        phoneNo: data["PhoneNumber"] ?? '',
        password: data["Password"] ?? '',
        address: data["Address"] ?? '',
        city: data["City"] ?? '',
        country: data["Country"] ?? '',
        id: document.id,
        firstName: data["FirstName"] ?? '',
        imageUrl: data["ImageUrl"] ?? '',
        preferences: data['Preferences'] ?? '',
        propertyIds: List<String>.from(data["PropertyIds"] ?? []), // And this line
        savedProperties: List<String>.from(data["SavedProperties"] ?? []),
        favoriteAgents: List<String>.from(data["FavoriteAgents"] ?? []),
        favoriteProperties: List<String>.from(data["FavoriteProperties"] ?? []),
      );
    } on Exception catch (e) {
      print('Error in ClientModel.fromSnapshot: $e');
      throw e;
    }
  }

}