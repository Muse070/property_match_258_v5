import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/explore/screens/property_details.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/home/controllers/home_controller.dart';
import 'package:property_match_258_v5/model/property_models/commercial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/industrial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/land_property_model.dart';
import 'package:property_match_258_v5/model/property_models/residential_property_model.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controllers/propert_controller/property_controller.dart';
import '../../../../../model/property_models/property_model.dart';
import '../../../../../model/user_models/agent_model.dart';
import '../../../../../model/user_models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  var images = {
    "welcome_one.jpg": "buying",
    "welcome_two.jpg": "finding",
    "welcome_three.jpg": "selling",
    "find_house.jpg": "buying",
  };

  // final controller = Get.put(GetUserController());
  final _userRepo = Get.find<UserRepository>();
  final _propertyController = Get.find<PropertyController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'img/258_white_no_bg.png', // replace with your asset image path
              fit: BoxFit.cover, // adjust as needed
              height: 40.sp, // adjust as needed
            ),
            Text(
              "Property Match",
              style:
              TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.white),
            )
          ],
        ),
        centerTitle: true,
      ),
      body: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: RefreshIndicator(
                  onRefresh: () async {
                    final email = _userRepo.currentUser.value?.email;
                    await _userRepo.getUserDetails(email!);
                    await _userRepo.getProperties();
                    print("Successfully Refreshed");
                  },
                  child: ListView(
                      children: [
                        SizedBox(
                          child: Container(
                            padding:
                            EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
                            color: Colors.grey.shade200,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Location',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                _locationCard(),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                Text(
                                  'Explore Our Properties',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                propertyCard()
                              ],
                            ),
                          ),
                        ),
                      ]),
                ),
              )


      );
  }

  Widget _locationCard() {
    return SizedBox(
      height: 7.h,
      width: 100.w,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.5.w), // adjust as needed
        ),
        elevation: 0.2,
        child: Container(
          child: Obx(() {
            if (_userRepo.currentAddress.value.isEmpty) {
              // Show a Shimmer effect if the address is not yet available
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Row(
                    children: [
                      Container(
                        width: 14.sp,
                        height: 14.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Container(
                        width: 80.w, // adjust as needed
                        height: 14.sp, // adjust as needed
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Show the address once it's available
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.locationDot,
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _userRepo.currentAddress.value,
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              );
            }
          }),
        ),
      ),
    );
  }

  Widget agentTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Meet Our Agents',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () {
            // Add functionality here...
          },
          child: Text(
            'View All',
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPlaceholder(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white70,
      highlightColor: Colors.grey[300]!,
      child: SizedBox(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          elevation: 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w,),
                    Container(
                      width: 50.w, // adjust as needed
                      height: 10.h, // adjust as needed
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              // Placeholder for the property image
              Container(
                height: 50.h,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50.w, // adjust as needed
                      height: 16.h, // adjust as needed
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      width: 80.w, // adjust as needed
                      height: 10.h, // adjust as needed
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Container(
                      width: 60.w, // adjust as needed
                      height: 10.h, // adjust as needed
                      color: Colors.grey,
                    ),
                    // Placeholder for a circle
                    SizedBox(height: 2.h),
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    // ... add more placeholders as needed
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget propertyCard() {
    return Obx(() {
      if (_userRepo.properties.isEmpty) {
        return buildPlaceholder(context);
      } else {
        return Column(
          children: _userRepo.properties.map((property) {
            Future<AgentModel> agentModel =
            _propertyController.getAgentDetailsForProperty(
                property.agentId);
            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: PropertyCard(
                propertyModel: property,
                agentModel: agentModel,
              ),
            );
          }).toList(),
        );
      }
    });

  }
}

class PropertyCard extends StatelessWidget {
  final PropertyModel propertyModel;
  final Future<AgentModel> agentModel;

  const PropertyCard({super.key, required this.propertyModel, required this.agentModel});

  String formatPrice(String price) {
    double value = double.parse(price);
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

  String formatSquareMeters(String squareMeters) {
    return '${double.parse(squareMeters)} m²';
  }

  Widget buildPlaceholder(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          elevation: 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 2.w,),
                    Container(
                      width: 50.w, // adjust as needed
                      height: 10.h, // adjust as needed
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              // Placeholder for the property image
              Container(
                height: 15.h,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50.w, // adjust as needed
                      height: 16.h, // adjust as needed
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 1.2.w, vertical: 0.3.h), // adjust as needed
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (propertyModel is ResidentialModel) {
      var property = propertyModel as ResidentialModel;

      return FutureBuilder<AgentModel>(
          future: agentModel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildPlaceholder(context);
            } else if (snapshot.hasError) {
              return Text('Error loading agent details'); // Handle error case
            } else if (!snapshot.hasData) {
              return Text(
                  'No agent details available'); // Handle empty data case
            } else {
              final AgentModel agent = snapshot.data!;

              return SizedBox(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => PropertyDetails(agentDetails: agent, propertyDetails: property));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white,
                    elevation: 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  agent.imageUrl != null && agent.imageUrl!.isNotEmpty
                                      ? CircleAvatar(
                                    radius: 5.w,
                                    backgroundImage: NetworkImage(agent.imageUrl!),
                                  )
                                      : ProfilePicture(
                                    name: agent.firstName.isNotEmpty
                                        ? "${agent.firstName} ${agent.lastName}"
                                        : "",
                                    radius: 5.w,
                                    fontsize: 9.sp,
                                  ),
                                  SizedBox(width: 2.w,),
                                  Text("${agent.firstName} ${agent.lastName}")
                                ],
                              ),
                              SizedBox(height: 0.3.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.locationDot,
                                    size: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(
                                    "${property.address}, ${property.city}",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600]),
                                  ),
                                  SizedBox(
                                    height: 0.3.h,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Assuming property.images is a list of image URLs
                        Image.network(
                          "${property.images[0]}.jpg",
                          fit: BoxFit.fitWidth,
                          height: 30.h,
                          width: 100.w,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatPrice(property.price),
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
                              SizedBox(height: 0.3.h),
                              Text(
                                "${property.propertyType} ${property.propertyOption}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[900],
                                ),
                              ),
                              SizedBox(height: 0.3.h),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Card(
                                        elevation: 0.2,
                                        color: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(1.h),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.5.w, vertical: 1.1.h),
                                          child: Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.bed,
                                                  size: 10.sp,
                                                  color: Colors.black87),
                                              SizedBox(
                                                width: 1.5.w,
                                              ),
                                              Text(
                                                "${property.numOfBedrooms} bds",
                                                style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color:
                                                    Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Card(
                                        elevation: 0.2,
                                        color: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(1.h),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.5.w, vertical: 1.1.h),
                                          child: Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.bath,
                                                  size: 10.sp,
                                                  color: Colors.black87),
                                              SizedBox(
                                                width: 1.5.w,
                                              ),
                                              Text(
                                                "${property.numOfBathrooms} bths",
                                                style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color:
                                                    Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Card(
                                        elevation: 0.2,
                                        color: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(1.h),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.5.w, vertical: 1.1.h),
                                          child: Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.ruler,
                                                  size: 10.sp,
                                                  color: Colors.black87),
                                              SizedBox(
                                                width: 1.5.w,
                                              ),
                                              Text(
                                                formatSquareMeters(property.squareMeters),
                                                style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color:
                                                    Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
      );
    }
    else if (propertyModel is CommercialModel) {
      var property = propertyModel as CommercialModel;

      return FutureBuilder<AgentModel>(
          future: agentModel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildPlaceholder(context);
            } else if (snapshot.hasError) {
              return Text('Error loading agent details'); // Handle error case
            } else if (!snapshot.hasData) {
              return Text(
                  'No agent details available'); // Handle empty data case
            } else {
              final AgentModel agent = snapshot.data!;

              return SizedBox(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => PropertyDetails(agentDetails: agent, propertyDetails: property));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white,
                    elevation: 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  agent.imageUrl != null && agent.imageUrl!.isNotEmpty
                                      ? CircleAvatar(
                                    radius: 10.w,
                                    backgroundImage: NetworkImage(agent.imageUrl!),
                                  )
                                      : ProfilePicture(
                                    name: agent.firstName.isNotEmpty
                                        ? "${agent.firstName} ${agent.lastName}"
                                        : "",
                                    radius: 5.w,
                                    fontsize: 9.sp,
                                  ),
                                  SizedBox(width: 2.w,),
                                  Text("${agent.firstName} ${agent.lastName}")
                                ],
                              ),
                              SizedBox(height: 0.3.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.locationDot,
                                    size: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(
                                    "${property.address}, ${property.city}",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600]),
                                  ),
                                  SizedBox(
                                    height: 0.3.h,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Assuming property.images is a list of image URLs
                        Image.network(
                          property.images[0],
                          fit: BoxFit.cover,
                          height: 30.h,
                          width: 100.w,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatPrice(property.price),
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
                              SizedBox(height: 0.3.h),
                              Text(
                                "${property.propertyType} ${property.propertyOption}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[900],
                                ),
                              ),
                              SizedBox(height: 0.3.h),
                              Row(
                                children: [
                                  Card(
                                    elevation: 0.2,
                                    color: Colors.grey[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1.h),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1.5.w, vertical: 1.1.h),
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.stairs,
                                              size: 10.sp,
                                              color: Colors.black87),
                                          SizedBox(
                                            width: 1.5.w,
                                          ),
                                          Text(
                                            "${property.numOfFloors} flrs",
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color:
                                                Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Card(
                                    elevation: 0.2,
                                    color: Colors.grey[100],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(1.h),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1.5.w, vertical: 1.1.h),
                                      child: Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.ruler,
                                              size: 10.sp,
                                              color: Colors.black87),
                                          SizedBox(
                                            width: 1.5.w,
                                          ),
                                          Text(
                                            formatSquareMeters(property.squareMeters),
                                            style: TextStyle(
                                                fontSize: 10.sp,
                                                color:
                                                Colors.black87),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
      );
    }
    else if (propertyModel is IndustrialModel) {
      var property = propertyModel as IndustrialModel;
      return FutureBuilder<AgentModel>(
          future: agentModel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildPlaceholder(context);
            } else if (snapshot.hasError) {
              return Text('Error loading agent details'); // Handle error case
            } else if (!snapshot.hasData) {
              return Text(
                  'No agent details available'); // Handle empty data case
            } else {
              final AgentModel agent = snapshot.data!;

              return SizedBox(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => PropertyDetails(agentDetails: agent, propertyDetails: property));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white,
                    elevation: 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  agent.imageUrl != null && agent.imageUrl!.isNotEmpty
                                      ? CircleAvatar(
                                    radius: 10.w,
                                    backgroundImage: NetworkImage(agent.imageUrl!),
                                  )
                                      : ProfilePicture(
                                    name: agent.firstName.isNotEmpty
                                        ? "${agent.firstName} ${agent.lastName}"
                                        : "",
                                    radius: 5.w,
                                    fontsize: 9.sp,
                                  ),
                                  SizedBox(width: 2.w,),
                                  Text("${agent.firstName} ${agent.lastName}")
                                ],
                              ),
                              SizedBox(height: 0.3.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.locationDot,
                                    size: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(
                                    "${property.address}, ${property.city}",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600]),
                                  ),
                                  SizedBox(
                                    height: 0.3.h,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Assuming property.images is a list of image URLs
                        Image.network(
                          property.images[0],
                          fit: BoxFit.cover,
                          height: 30.h,
                          width: 100.w,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatPrice(property.price),
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
                              SizedBox(height: 0.3.h),
                              Text(
                                "${property.propertyType} ${property.propertyOption}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[900],
                                ),
                              ),
                              SizedBox(height: 0.3.h),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Card(
                                        elevation: 0.2,
                                        color: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(1.h),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.5.w, vertical: 1.1.h),
                                          child: Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.stairs,
                                                  size: 10.sp,
                                                  color: Colors.black87),
                                              SizedBox(
                                                width: 1.5.w,
                                              ),
                                              Text(
                                                "${property.numOfFloors} flrs",
                                                style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color:
                                                    Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Card(
                                        elevation: 0.2,
                                        color: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(1.h),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.5.w, vertical: 1.1.h),
                                          child: Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.rulerCombined,
                                                  size: 10.sp,
                                                  color: Colors.black87),
                                              SizedBox(
                                                width: 1.5.w,
                                              ),
                                              Text(
                                                "${formatSquareMeters(property.areaPerFloor)}/ flr",
                                                style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color:
                                                    Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Card(
                                        elevation: 0.2,
                                        color: Colors.grey[100],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(1.h),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.5.w, vertical: 1.1.h),
                                          child: Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.ruler,
                                                  size: 10.sp,
                                                  color: Colors.black87),
                                              SizedBox(
                                                width: 1.5.w,
                                              ),
                                              Text(
                                                formatSquareMeters(property.totalArea),
                                                style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color:
                                                    Colors.black87
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
      );
    }
    else if (propertyModel is LandModel) {
      var property = propertyModel as LandModel;
      return FutureBuilder<AgentModel>(
          future: agentModel,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return buildPlaceholder(context);
            } else if (snapshot.hasError) {
              return Text('Error loading agent details'); // Handle error case
            } else if (!snapshot.hasData) {
              return Text(
                  'No agent details available'); // Handle empty data case
            } else {
              final AgentModel agent = snapshot.data!;

              return SizedBox(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => PropertyDetails(agentDetails: agent, propertyDetails: property));
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white,
                    elevation: 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  agent.imageUrl != null && agent.imageUrl!.isNotEmpty
                                      ? CircleAvatar(
                                    radius: 10.w,
                                    backgroundImage: NetworkImage(agent.imageUrl!),
                                  )
                                      : ProfilePicture(
                                    name: agent.firstName.isNotEmpty
                                        ? "${agent.firstName} ${agent.lastName}"
                                        : "",
                                    radius: 5.w,
                                    fontsize: 9.sp,
                                  ),
                                  SizedBox(width: 2.w,),
                                  Text("${agent.firstName} ${agent.lastName}")
                                ],
                              ),
                              SizedBox(height: 0.3.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.locationDot,
                                    size: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(
                                    "${property.address}, ${property.city}",
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey[600]),
                                  ),
                                  SizedBox(
                                    height: 0.3.h,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Assuming property.images is a list of image URLs
                        Image.network(
                          property.images[0],
                          fit: BoxFit.cover,
                          height: 30.h,
                          width: 100.w,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatPrice(property.price),
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
                              SizedBox(height: 0.3.h),
                              Text(
                                "${property.propertyType} ${property.propertyOption}",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[900],
                                ),
                              ),
                              SizedBox(height: 0.3.h),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Card(
                                        color: Colors.grey[100],
                                        elevation: 0.2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(1.h),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 1.5.w, vertical: 1.1.h),
                                          child: Row(
                                            children: [
                                              FaIcon(FontAwesomeIcons.ruler,
                                                  size: 10.sp,
                                                  color: Colors.black87),
                                              SizedBox(
                                                width: 1.5.w,
                                              ),
                                              Text(
                                                formatSquareMeters(property.squareMeters),
                                                style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color:
                                                    Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          }
      );
    }
    else {
      return Container();
    }
  }
}

class AgentCircleAvatar extends StatelessWidget {
  final String imageUrl;
  final String agentName;

  AgentCircleAvatar({required this.imageUrl, required this.agentName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        imageUrl.isNotEmpty
            ? CircleAvatar(
          radius: 10.w,
          backgroundImage: NetworkImage(imageUrl),
        )
            : ProfilePicture(
          name: agentName,
          radius: 10.w,
          fontsize: 12.sp,
        ),
        Text(agentName),
      ],
    );
  }
}

class AgentCard extends StatelessWidget {
  final String imageUrl;
  final String agentName;

  AgentCard({required this.imageUrl, required this.agentName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Agent card tapped.");
      },
      child: SizedBox(
        height: 10.h,
        width: 45.w,
        child: Card(
          elevation: 0.2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imageUrl.isNotEmpty
                    ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(imageUrl),
                )
                    : ProfilePicture(
                  name: agentName,
                  radius: 10.w,
                  fontsize: 14.sp,
                ),
                SizedBox(height: 10),
                Text(
                  agentName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AgentList extends StatelessWidget {
  final List<Map<String, String>> agents;

  AgentList({required this.agents});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: agents.length,
      itemBuilder: (context, index) {
        return AgentCard(
          imageUrl: agents[index]['imageUrl']!,
          agentName: agents[index]['name']!,
        );
      },
    );
  }
}
