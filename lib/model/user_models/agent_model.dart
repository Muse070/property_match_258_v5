import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:property_match_258_v5/model/user_models/user_model.dart';

class AgentModel extends UserModel {
  String? agencyName;
  String? agencyImage;
  final String bio;

  AgentModel({
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
    super.imageUrl,
    super.propertyIds,
    super.favoriteProperties,
    required this.bio,
    this.agencyImage,
    this.agencyName,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = super.toJson();

    map["AgencyName"] = agencyName;
    map["AgencyImage"] = agencyImage;
    map["Bio"] = bio;

    return map;
  }


  factory AgentModel.fromSnapshot(DocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return AgentModel(
      email: data["Email"] ?? '',
      userType: data["UserType"] ?? '',
      lastName: data["LastName"] ?? '',
      phoneNo: data["PhoneNumber"] ?? '',
      password: data["Password"] ?? '',
      id: document.id,
      firstName: data["FirstName"] ?? '',
      address: data["Address"] ?? '',
      city: data["City"] ?? '',
      country: data["Country"] ?? '',
      imageUrl: data["ImageUrl"] ?? '',
      propertyIds: List<String>.from(data["PropertyIds"] ?? []), // And this line
      agencyImage: data["AgencyImage"] ?? '',
      agencyName: data["AgencyName"] ?? '',
      bio: data["Bio"] ?? '',
      favoriteProperties: List<String>.from(data["FavoriteProperties"] ?? []),
    );
  }

}