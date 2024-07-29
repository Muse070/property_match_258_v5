import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/controllers/favoritesController/favorites_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/explore/screens/property_details.dart';
import 'package:property_match_258_v5/model/property_models/commercial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/industrial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/land_property_model.dart';
import 'package:property_match_258_v5/model/property_models/property_model.dart';
import 'package:property_match_258_v5/model/property_models/residential_property_model.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:property_match_258_v5/widgets/explore_page_widgets/imageCarousel.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controllers/propert_controller/property_controller.dart';
import '../../../../../model/user_models/agent_model.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late FavoriteController _favoriteController;
  final _propertyController = Get.find<PropertyController>();
  final _userRepo = Get.find<UserRepository>();

  @override
  void initState() {
    super.initState();
    _favoriteController = Get.find<FavoriteController>();
  }

  @override
  Widget build(BuildContext context) {
    print("Favorite properties list is: ${_favoriteController.properties}");
    return Obx(() {
      if (_favoriteController.isLoading.isTrue) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black87,
            title: Text(
              "Favorites",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                fontSize: 14.sp,
              ),
            ),
          ),
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // If the data is loaded but the list is empty
      if (_favoriteController.properties.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black87,
            title: Text(
              "Favorites",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: "Roboto",
                fontSize: 14.sp,
              ),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.6,
                  child: FaIcon(
                    FontAwesomeIcons.bookmark,
                    size: 50.sp,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  "Your Favorites List is Empty",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Start saving properties you love to browse them later.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      print("Favorite properties list is: ${_favoriteController.properties}");
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text(
            "Favorites",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontFamily: "Roboto",
              fontSize: 14.sp,
            ),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirm Delete'),
                      content: Text(
                          'Are you sure you want to delete all favorite properties?'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Delete All'),
                          onPressed: () {
                            // Call your method to delete all favorite agents here
                            try {
                              _favoriteController.deleteAllFavorites();
                              print("Properties have been deleted");
                            } on Exception catch (e) {
                              print("Properties have not been deleted");
                            }
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: IconTheme(
                data: IconThemeData(
                  color: Colors.white,
                  size: 12.sp,
                ),
                child: FaIcon(FontAwesomeIcons.trash),
              ),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
          color: Colors.grey.shade200,
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Obx(() {
              print("Favorite properties printed now are: ${_favoriteController
                  .properties}");
              return Container(
                child: Column(
                  children: _favoriteController.properties.map((property) {
                    final agentDetailsFuture = _propertyController
                        .getAgentDetailsForProperty(property.agentId);

                    return FutureBuilder<AgentModel?>(
                      future: agentDetailsFuture,
                      builder: (context, agentSnapshot) {
                        if (agentSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (agentSnapshot.hasError) {
                          return Text('Error: ${agentSnapshot.error}');
                        } else {
                          final agentDetails = agentSnapshot.data;
                          Widget card;

                          if (property is ResidentialModel) {
                            card = SizedBox(
                                height: 39.h,
                                width: 100.w,
                                child: favoriteCard(() {
                                  Get.to(() =>
                                      PropertyDetails(
                                          agentDetails: agentDetails,
                                          propertyDetails: property));
                                }, property)
                            );
                          } else if (property is CommercialModel) {
                            card = SizedBox(
                                height: 39.h,
                                width: 100.w,
                                child: favoriteCard(() {
                                  Get.to(() =>
                                      PropertyDetails(
                                          agentDetails: agentDetails,
                                          propertyDetails: property));
                                }, property));
                          } else if (property is IndustrialModel) {
                            card = SizedBox(
                                height: 39.h,
                                width: 100.w,
                                child: favoriteCard(() {
                                  Get.to(() =>
                                      PropertyDetails(
                                          agentDetails: agentDetails,
                                          propertyDetails: property));
                                }, property));
                          } else if (property is LandModel) {
                            card = SizedBox(
                                height: 39.h,
                                width: 100.w,
                                child: favoriteCard(() {
                                  Get.to(() =>
                                      PropertyDetails(
                                          agentDetails: agentDetails,
                                          propertyDetails: property));
                                }, property));
                          } else {
                            card = Container();
                          }

                          return Column(
                            children: <Widget>[
                              card,
                              SizedBox(
                                height: 2.5.h,
                              )
                            ],
                          );
                        }
                      },
                    );
                  }).toList(),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  Widget favoriteCard(VoidCallback onTap, PropertyModel property) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(children: [
        Card(
          color: Colors.white,
          elevation: 0.1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(1.h)),
                child: ImageCarousel(
                  imageList: property.images,
                  height: 25,
                  width: 100,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatPrice(property),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[900],
                          ),
                        ),
                        Container(
                          height: 3.5.h,
                          width: 18.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.2.w, vertical: 0.3.h),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.h)),
                          ),
                          child: Center(
                            child: Text(
                              property.saleOrRent,
                              style: TextStyle(
                                  color: Color(0xFF80CBC4),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    Text(
                      "${property.propertyType} (${property.propertyOption})",
                      style:
                      TextStyle(fontSize: 11.sp, color: Colors.grey[800]),
                    ),
                    SizedBox(
                      height: 0.5.h,
                    ),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 12.sp,
                          color: Colors.black87,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          "${property.address}, ${property.city}",
                          style: TextStyle(
                              fontSize: 10.sp, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0.h,
          left: 84.w,
          child: IconButton(
            onPressed: () {
              setState(() {
                _favoriteController.toggleFavoriteProduct(property.id);
              });
            },
            icon: IconTheme(
              data: IconThemeData(
                color: _favoriteController.isFavorite(property.id)
                    ? Colors.red
                    : const Color(0xFF005555),
                size: 16.sp,
              ),
              child: FaIcon(_favoriteController.isFavorite(property.id)
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart),
            ),
          ),
        )
      ]),
    );
  }

  String formatPrice(PropertyModel propertyModel) {
    double value = double.parse(propertyModel.price);
    NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');

    try {
      if (propertyModel.currency == 'ZMW') {
        return 'ZMW ${formatter.format(
            value)}'; // Display the full price with commas
      } else if (propertyModel.currency == 'USD') {
        return 'USD ${formatter.format(
            value)}';
      } else {
        return '';
      }
    } on Exception catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "Unexpected error: $e");
      return '';
    }
  }
}