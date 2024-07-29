import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class PropertyModel with ChangeNotifier {
  late final String id;
  late final String agentId;
  late final String saleOrRent;
  late final String propertyType;
  late final String propertyOption;
  late final String price;
  late final String description;
  late final List<String> amenities;
  late final String address;
  late final String city;
  late final String country;
  late final double latitude;
  late final double longitude;
  late final List<String> images;
  late final List<String> documents;
  late final String currency;

  PropertyModel({
    required this.id,
    required this.agentId,
    required this.saleOrRent,
    required this.propertyType,
    required this.propertyOption,
    required this.price,
    required this.description,
    required this.amenities,
    required this.address,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.documents,
    required this.currency,

  });

  Map<String, dynamic> toJson() {
    return {
      "Id": id,
      "AgentId": agentId,
      "SaleOrRent": saleOrRent,
      "PropertyType": propertyType,
      "PropertyOption": propertyOption,
      "Price": price,
      "Description": description,
      "Amenities": amenities,
      "Address": address,
      "City": city,
      "Country": country,
      "Latitude": latitude,
      "Longitude": longitude,
      "Images": images,
      "Documents": documents,
      "Currency": currency,
    };
  }



  factory PropertyModel.fromSnapshot(DocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return PropertyModel(
      id: document.id,
      agentId: data["AgentId"] ?? '',
      saleOrRent: data["SaleOrRent"] ?? '',
      propertyType: data["PropertyType"] ?? '',
      propertyOption: data["PropertyOption"] ?? '',
      price: data["Price"] ?? '',
      description: data["Description"],
      amenities: List<String>.from(data["Amenities"] ?? []),
      address: data["Address"] ?? '',
      city: data["City"] ?? '',
      country: data["Country"] ?? '',
      latitude: data["Latitude"] ?? 0.0,
      longitude: data["Longitude"] ?? 0.0,
      images: List<String>.from(data["Images"] ?? []),
      documents: List<String>.from(data["Documents"] ?? []),
      currency: data["Currency"] ?? '',
    );
  }
}