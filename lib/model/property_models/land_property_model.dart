import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:property_match_258_v5/model/property_models/property_model.dart';

class LandModel extends PropertyModel{
  late final String squareMeters;

  LandModel({
    required super.id,
    required super.agentId,
    required super.saleOrRent,
    required super.propertyType,
    required super.propertyOption,
    required super.price,
    required super.description,
    required super.amenities,
    required super.address,
    required super.city,
    required super.country,
    required super.latitude,
    required super.longitude,
    required super.images,
    required super.documents,
    required this.squareMeters,
    required super.currency,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      "SquareMeters": squareMeters,
    } as Map<String, dynamic>;
  }

  factory LandModel.fromSnapshot(DocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return LandModel(
      id: document.id,
      agentId: data["AgentId"] ?? '',
      saleOrRent: data["SaleOrRent"] ?? '',
      propertyType: data["PropertyType"] ?? '',
      propertyOption: data["PropertyOption"] ?? '',
      price: data["Price"] ?? '',
      squareMeters: data["SquareMeters"] ?? '',
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
