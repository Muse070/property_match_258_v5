import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/repository/user_repository/agent_repository.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../controllers/favoritesController/favorites_controller.dart';
import '../../../../../../model/property_models/commercial_property_model.dart';
import '../../../../../../model/property_models/industrial_property_model.dart';
import '../../../../../../model/property_models/land_property_model.dart';
import '../../../../../../model/property_models/property_model.dart';
import '../../../../../../model/property_models/residential_property_model.dart';
import '../../../../../../model/user_models/agent_model.dart';
import '../../../../../../widgets/explore_page_widgets/imageCarousel.dart';
import '../../../explore/screens/property_details.dart';

class AgentDetails extends StatefulWidget {
  final AgentModel? agentDetails;

  const AgentDetails({super.key, required this.agentDetails});

  @override
  State<AgentDetails> createState() => _AgentDetailsState();
}

class _AgentDetailsState extends State<AgentDetails> {
  final _agentRepo = Get.find<AgentRepository>();
  final _favoriteController = Get.find<FavoriteController>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          "${widget.agentDetails?.firstName} ${widget.agentDetails
              ?.lastName}",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontFamily: "Roboto",
              fontSize: 14.sp),
        ),
        // titleTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
        leading: IconButton(
          icon: IconTheme(
            data: IconThemeData(
              size: 14.sp,
              color: Colors.white,
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          Obx(() {
            bool isAgentFavorite = _agentRepo.isFavorite[widget.agentDetails!.id] ?? false;
            return IconButton(
              onPressed: () async {
                if (isAgentFavorite) {
                  // If the agent is now a favorite, remove them from Firestore
                  await _agentRepo.removeFavoriteAgent(widget.agentDetails!.id);
                } else {
                  // If the agent is no longer a favorite, add them to Firestore
                  await _agentRepo.addFavoriteAgent(widget.agentDetails!.id);

                }
              },
              icon: IconTheme(
                data: IconThemeData(
                  color: isAgentFavorite ? Colors.red : Colors.white,
                  size: 14.sp,
                ),
                child: FaIcon(isAgentFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart),
              ),
            );
          }),
          IconButton(
            onPressed: () {},
            icon: IconTheme(
              data: IconThemeData(
                color: Colors.white,
                size: 14.sp,
              ),
              child: FaIcon(FontAwesomeIcons.comment),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<PropertyModel>>(
        future: _agentRepo.getAgentsProperties(widget.agentDetails!.id),
        // Fetch the data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show a loading spinner while waiting
          }
          else if (snapshot.hasError) {
            return Text(
                'Error: ${snapshot
                    .error}'); // Show error message if something went wrong
          } else {
            final properties = snapshot.data;
            return Container(
              padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.5.w),
              color: Colors.grey.shade200,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 32.h,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _appBar(widget.agentDetails),
                    ),
                    backgroundColor: Colors.grey.shade200,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final property = properties?[index];
                            print(
                                "Fetched properties for use are: ${properties?[index]
                                    .address}");

                            Widget card;

                            if (property is ResidentialModel) {
                              card = SizedBox(
                                  height: 39.h,
                                  width: 100.w,
                                  child: favoriteCard(() {
                                    Get.to(() =>
                                        PropertyDetails(
                                            agentDetails: widget.agentDetails,
                                            propertyDetails: property));
                                  }, property));
                            } else if (property is CommercialModel) {
                              card = SizedBox(
                                  height: 39.h,
                                  width: 100.w,
                                  child: favoriteCard(() {
                                    Get.to(() =>
                                        PropertyDetails(
                                            agentDetails: widget.agentDetails,
                                            propertyDetails: property));
                                  }, property));
                            } else if (property is IndustrialModel) {
                              card = SizedBox(
                                  height: 39.h,
                                  width: 100.w,
                                  child: favoriteCard(() {
                                    Get.to(() =>
                                        PropertyDetails(
                                            agentDetails: widget.agentDetails,
                                            propertyDetails: property));
                                  }, property));
                            } else if (property is LandModel) {
                              card = SizedBox(
                                  height: 39.h,
                                  width: 100.w,
                                  child: favoriteCard(() {
                                    Get.to(() =>
                                        PropertyDetails(
                                            agentDetails: widget.agentDetails,
                                            propertyDetails: property));
                                  }, property));
                            } else {
                              card = Container();
                            }
                            // ... rest of your code ...
                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  card,
                                  SizedBox(height: 1.5.h),
                                ]);
                          },

                      childCount: properties?.length,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
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
                          formatPrice(property.price, property.currency),
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
                    : Colors.white,
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

  String formatPrice(String price, String currency) {
    if (currency == "ZMW"){
      double value = double.parse(price);
    final formatCurrency = NumberFormat("#,##0", "en_US");
    return 'K${formatCurrency.format(value)}';
  } else {
      double value = double.parse(price);
      final formatCurrency = NumberFormat("#,##0", "en_US");
      return '\$${formatCurrency.format(value)}';
    }
  }

  Widget _appBar(AgentModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                ? CircleAvatar(
              radius: 10.w,
              backgroundImage: NetworkImage(user.imageUrl!),
            )
                : ProfilePicture(
                name: "${user?.firstName} ${user?.lastName}",
                radius: 10.w,
                fontsize: 18.sp),
            SizedBox(
              width: 7.w,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.suitcase,
                      size: 12.sp,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      user!.agencyName!,
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                          fontFamily: "Roboto"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.solidEnvelope,
                      size: 12.sp,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      user!.email,
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                          fontFamily: "Roboto"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.phone,
                      size: 12.sp,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      user.phoneNo,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                          fontFamily: "Roboto"),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
        SizedBox(
          height: 1.5.h,
        ),
        Text(
          "Bio",
          style:
          TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp),
        ),
        // SizedBox(
        //   height: 1.5.h,
        // ),
        SizedBox(
          height: 12.h,
          width: 100.w,
          child: Card(
            elevation: 0.2,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.bio,
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                        fontSize: 9.sp,
                        fontFamily: "Roboto"),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 1.5.h,
        ),
        Text(
          "Listings",
          style:
          TextStyle(fontWeight: FontWeight.w500, fontSize: 12.sp),
        ),
        // SizedBox(
        //   height: 1.5.h,
        // ),
      ],
    );
  }
}
