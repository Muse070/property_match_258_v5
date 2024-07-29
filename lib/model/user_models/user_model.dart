import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserModel with ChangeNotifier{
  late final String id;
  late final String firstName;
  late final String lastName;
  late final String email;
  late final String phoneNo;
  late final String password;
  late final String address;
  late final String city;
  late final String country;
  final String userType;
  String? imageUrl;
  List<String>? propertyIds;// Add this line
  List<String>? favoriteProperties;


  UserModel({
    required this.email,
    required this.userType,
    required this.lastName,
    required this.phoneNo,
    required this.password,
    required this.id,
    required this.firstName,
    required this.address,
    required this.city,
    required this.country,
    this.imageUrl,
    this.propertyIds,
    this.favoriteProperties,
  });

  toJson() {
    return {
      "Id": id,
      "FirstName": firstName,
      "LastName": lastName,
      "Email": email,
      "PhoneNumber": phoneNo,
      "Password": password,
      "UserType": userType,
      "Address": address,
      "City": city,
      "Country": country,
      "ImageUrl": imageUrl,
      "PropertyIds": propertyIds, // And this line
      "FavoriteProperties": favoriteProperties,
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return UserModel(
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
      propertyIds: List<String>.from(data["PropertyIds"] ?? []), // And this line
      favoriteProperties: List<String>.from(data["FavoriteProperties"] ?? []),
    );
  }
}