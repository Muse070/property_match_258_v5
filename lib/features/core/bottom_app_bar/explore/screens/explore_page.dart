import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/controllers/propert_controller/property_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/explore/screens/property_details.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/explore/screens/search_screen.dart';
import 'package:property_match_258_v5/model/property_models/industrial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/land_property_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controllers/favoritesController/favorites_controller.dart';
import '../../../../../model/property_models/commercial_property_model.dart';
import '../../../../../model/property_models/property_model.dart';
import '../../../../../model/property_models/residential_property_model.dart';
import '../../../../../model/user_models/agent_model.dart';
import '../../../../../repository/user_repository/user_repository.dart';
import '../../../../../widgets/agent_property_listing_widgets/custom_marker.dart';
import '../../../../../widgets/explore_page_widgets/customRow.dart';
import '../../../../../widgets/explore_page_widgets/imageCarousel.dart';
import '../../../../../widgets/explore_page_widgets/moreDetailsButton.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with TickerProviderStateMixin {
  // final GlobalKey _markerIconKey = GlobalKey();

  final Set<Marker> _markers = {};

  final _userRepo = Get.find<UserRepository>();

  MapType _currentMapType = MapType.hybrid;

  bool isMarkerOffScreen = false;

  RxString priceTag = "".obs;

  BitmapDescriptor? customIcon;

  bool _isLoading = true; // Add this line to track loading state

  double lat = 0.0;
  double lng = 0.0;

  // final Completer<GoogleMapController> _mapController = Completer();

  final FavoriteController _favoriteController = Get.find<FavoriteController>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final PropertyController _propertyController = Get.find<PropertyController>();
  RxList lProperties = [].obs;

  List<Map<String, dynamic>> propertyData = [];

  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // lProperties = _userRepository.properties;
      print("Properties are: ${_userRepository.properties}");
      await _userRepo.getLocation().then((position) {
        lat = position.latitude;
        lng = position.longitude;
        print("Current location is: $lat $lng");
      });
      print("Init explore page");

      await fetchPropertyData().then((_) {
        for (var property in lProperties) {
          print("Marker before is $_markers");
          _markers.add(
              Marker(
                markerId: MarkerId(property.id),
                position: LatLng(property.latitude, property.longitude),
                infoWindow: InfoWindow(
                  title: property.address,
                  snippet: '\$${property.price}',
                ),
                onTap: () {
                  var mProperty = lProperties.firstWhere((p) => p.id == property.id);
                  Future<AgentModel> agentDetailsFuture =
                  _propertyController.getAgentDetailsForProperty(mProperty.agentId);
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.grey.shade300,
                    scrollControlDisabledMaxHeightRatio: 0.63,
                    enableDrag: false,
                    showDragHandle: true,
                    builder: (BuildContext context) {
                      return FutureBuilder<AgentModel>(
                        future: agentDetailsFuture,
                        builder:
                            (BuildContext context,
                            AsyncSnapshot<AgentModel> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return FractionallySizedBox(
                              heightFactor: 1.0,
                              child: Container(
                                child: _buildPropertyDetails(
                                    mProperty, snapshot.data),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              )
          );
          print("Marker after is $_markers");

        }

        setState(() {
          print("Map loading complete");
          print("markers are: $_markers");
          _isLoaded = true; // Mark loading as complete
        });

      });

      // .then((_){ WidgetsBinding.instance
      // .addPostFrameCallback((_) async => await _onBuildCompleted());});
      // print("All processes completed");
      //
      // setState(() {
      //   print("Map loading complete");
      //   print("The markers are: $_markers");
      //   _isLoaded = true; // Mark loading as complete
      // });
      // await fetchPropertyData().then((_) {
      //
      //   print("Property data is initialized");
      // });

      // .then((_){ WidgetsBinding.instance
      // .addPostFrameCallback((_) async => await _onBuildCompleted());});
      // print("All processes completed");
    });

    // print("property price is: ${properties.first.price}");
  }

  Future<void> fetchPropertyData() async {
    print("Starting to fetch property data for explore page");
    List<PropertyModel> propertyList = await _propertyController.getProperties();
    setState(() {
      lProperties.value = propertyList;
      print("Error properties is: ${lProperties}");
    });

  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
      _currentMapType == MapType.hybrid ? MapType.normal : MapType.hybrid;
      print("Map Type: $_currentMapType");
    });
  }

  // Future<void> fetchPropertyData() async {
  //   print("Starting to fetch property data for explore page");
  //   List<PropertyModel> propertyList =
  //       await _propertyController.getProperties();
  //   setState(() async {
  //     for (var propertyDoc in propertyList) {
  //       final mPropertyData = propertyDoc;
  //       // ... (rest of the fetching logic) ...
  //
  //       for (var property in _userRepository.properties) {
  //         final GlobalKey key = GlobalKey(); // Create a GlobalKey
  //         propertyData.add(property.copyWith(globalKey: key)); // Add the GlobalKey to your PropertyModel
  //
  //         // You can remove the old 'customMarker' entry from propertyData, as it's not needed anymore
  //         // propertyData.remove('customMarker'); // Remove this line if you don't need it
  //       }
  //
  //       _markers.add(Marker(
  //         // ... (markerId, position, infoWindow) ...
  //         position: LatLng(mPropertyData.latitude, mPropertyData.longitude),
  //         icon: BitmapDescriptor.bytes(
  //           await _getBytesFromWidget(
  //             Container(
  //               padding: EdgeInsets.all(8.0),
  //               color: Colors.blue,
  //               child: Text(
  //                 '\$${mPropertyData.price} | ${mPropertyData.address}',
  //                 style: TextStyle(color: Colors.white),
  //               ),
  //             ),
  //           ),
  //         ),
  //         markerId: MarkerId(mPropertyData.address),
  //       ));
  //     }
  //   });
  // }

  Future<Uint8List> _getBytesFromWidget(Widget widget) async {
    final boundary = widget.key as GlobalKey;
    RenderRepaintBoundary? boundaryRenderObject =
    boundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundaryRenderObject.toImage(pixelRatio: 1.7);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.black87,
              title: Text(
                "Explore",
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
                    Get.to(() => const PropertySearchScreen());
                  },
                  icon: FaIcon(
                    FontAwesomeIcons.magnifyingGlass,
                    size: 14.sp,
                    color: Colors.white,
                  ),
                )
              ]),
          body: Stack(children: [
            if (_isLoaded)
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(lat, lng),
                  zoom: 18,
                ),
                myLocationEnabled: true,
                mapType: _currentMapType,
                markers: _markers,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController mapController) async {
// await createCustomMarker(context, id);
                },
                onTap: (LatLng latLng) {},
                onLongPress: (LatLng latLng) {},
              ),
            if (!_isLoaded) // Conditionally show the loading indicator
              const Center(
                child: CircularProgressIndicator(),
              ),
            // ListView(
            //   children: [
            //     for (int i = 0; i < propertyData.length; i++)
            //       Transform.translate(
            //         offset: Offset(
            //           -MediaQuery.of(context).size.width * 2,
            //           -MediaQuery.of(context).size.height * 2,
            //         ),
            //         child: RepaintBoundary(
            //             key: propertyData[i]['globalKey'],
            //             child: propertyData[i]['customMarker']),
            //       )
            //   ],
            // ),
          ]),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: 5.5.h),
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF005555),
              elevation: 10,
              onPressed: _onMapTypeButtonPressed,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              child: const Icon(
                Icons.map,
                size: 36.0,
                color: Colors.white,
              ),
            ),
          ),
        ));
  }

  // Future<void> _onBuildCompleted() async {
  //   // Use WidgetsBinding.instance.endOfFrame to ensure the current frame is fully built.
  //   WidgetsBinding.instance.addPostFrameCallback((_) async {
  //     for (var value in propertyData) {
  //       try {
  //         await Future.delayed(Duration.zero);
  //         // Add this inner post-frame callback to wait for the specific marker's boundary.
  //         WidgetsBinding.instance.addPostFrameCallback((_) async {
  //           Marker marker = await _generateMarkersFromWidget(value);
  //           setState(() {
  //             // Use setState to trigger rebuild after marker is generated
  //             _markers[marker.markerId] = marker;
  //           });
  //         });
  //       } on Exception catch (e) {
  //         print("Error on _generateMarkersFromWidget: $e");
  //       }
  //     }
  //
  //     // Set _isLoaded AFTER all markers have been generated
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       setState(() {
  //         _isLoaded = true;
  //       });
  //     });
  //   });
  // }

  Future<Marker> _generateMarkersFromWidget(PropertyModel property) async {

    final GlobalKey key = GlobalKey();
    final customMarker = CustomMarker(price: property.price.obs, key: key);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Empty callback to ensure widget is built
    });

    print("Create boundary");
    final boundary = key.currentContext?.findRenderObject()
    as RenderRepaintBoundary;
    print("Boundary is: $boundary");

    if (boundary == null) {
      print("Warning: RenderRepaintBoundary not found for ${property.id}.");
      return Marker(markerId: MarkerId(""));
    }

    while (boundary.debugNeedsPaint) {
      print("Waiting for boundary to be painted.");
      await Future.delayed(const Duration(milliseconds: 10));
      // return _generateMarkersFromWidget(data);
    }

    try {
      print("Create image");
      final image = await boundary.toImage(pixelRatio: 1.7);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      print("Image created");

      return Marker(
        markerId: MarkerId(property.id),
        position: LatLng(property.latitude, property.longitude),
        icon: BitmapDescriptor.bytes(
          byteData!.buffer.asUint8List(),
        ),
        onTap: () {
          var mProperty = lProperties.firstWhere((p) => p.id == property.id);
          Future<AgentModel> agentDetailsFuture =
          _propertyController.getAgentDetailsForProperty(mProperty.agentId);
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.grey.shade300,
            scrollControlDisabledMaxHeightRatio: 0.63,
            enableDrag: false,
            showDragHandle: true,
            builder: (BuildContext context) {
              return FutureBuilder<AgentModel>(
                future: agentDetailsFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<AgentModel> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return FractionallySizedBox(
                      heightFactor: 1.0,
                      child: Container(
                        child: _buildPropertyDetails(mProperty, snapshot.data),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      );
    } on Exception catch (e) {
      print("Error generating marker image: $e");
      return Marker(markerId: MarkerId(""));
    }
  }

  Widget _buildPropertyDetails(
      PropertyModel property, AgentModel? agentDetails) {
    if (property is ResidentialModel) {
      ResidentialModel residentialProperty = property;
      final List<String> imageList = residentialProperty.images;
      String price = formatPrice(property.price);
      return SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 1.h,
                  ),
                  Stack(children: [
                    Card(
                      color: Colors.white,
                      elevation: 0.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(1.h)),
                            child: ImageCarousel(
                              imageList: imageList,
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
                                  children: [
                                    Text(
                                      price,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87),
                                    ),
                                    SizedBox(
                                      width: 4.w,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1.2.w, vertical: 0.3.h),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.h)),
                                      ),
                                      child: Text(
                                        "For Sale",
                                        style: TextStyle(
                                          color: Color(0xFF80CBC4),
                                          fontSize: 8.sp,
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
                                  style: TextStyle(
                                      fontSize: 11.sp, color: Colors.grey[800]),
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.locationDot,
                                      size: 12.sp,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      "${property.address}, ${property.city}",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    CustomRow(
                                        icon: FontAwesomeIcons.bed,
                                        text:
                                        residentialProperty.numOfBedrooms),
                                    SizedBox(width: 3.w),
                                    CustomRow(
                                        icon: FontAwesomeIcons.bath,
                                        text:
                                        residentialProperty.numOfBathrooms),
                                    SizedBox(width: 3.w),
                                    CustomRow(
                                        icon: FontAwesomeIcons.ruler,
                                        text: formatSquareMeters(
                                            residentialProperty.squareMeters)),
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
                      left: 82.w,
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                _favoriteController
                                    .toggleFavoriteProduct(property.id);
                              });
                            },
                            icon: Obx(
                                  () => IconTheme(
                                data: IconThemeData(
                                  color: _favoriteController
                                      .isFavorite(property.id)
                                      ? Colors.red
                                      : Colors.white70,
                                  size: 16.sp,
                                ),
                                child: FaIcon(
                                  _favoriteController.isFavorite(property.id)
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 1.h,
                  ),
                  // const Divider(),
                  SizedBox(
                    height: 1.h,
                  ),
                  MoreDetailsButton(
                    onPressed: () {
                      Get.to(() => PropertyDetails(
                        agentDetails: agentDetails,
                        propertyDetails: residentialProperty,
                      ));
                    },
                    label: "More Details",
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (property is CommercialModel) {
      CommercialModel commercialProperty = property;
      final List<String> imageList = commercialProperty.images;
      String price = formatPrice(property.price);
      return SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 1.h,
                  ),
                  Stack(children: [
                    Card(
                      color: Colors.white,
                      elevation: 0.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(1.h)),
                            child: ImageCarousel(
                              imageList: imageList,
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
                                  children: [
                                    Text(
                                      price,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87),
                                    ),
                                    SizedBox(
                                      width: 4.w,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1.2.w, vertical: 0.3.h),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.h)),
                                      ),
                                      child: Text(
                                        "For Sale",
                                        style: TextStyle(
                                          color: Color(0xFF80CBC4),
                                          fontSize: 8.sp,
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
                                  style: TextStyle(
                                      fontSize: 11.sp, color: Colors.grey[800]),
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.locationDot,
                                      size: 12.sp,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      "${property.address}, ${property.city}",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    CustomRow(
                                        icon: FontAwesomeIcons.stairs,
                                        text: commercialProperty.numOfFloors),
                                    SizedBox(width: 3.w),
                                    CustomRow(
                                        icon: FontAwesomeIcons.ruler,
                                        text: formatSquareMeters(
                                            commercialProperty.squareMeters)),
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
                      left: 82.w,
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                _favoriteController
                                    .toggleFavoriteProduct(property.id);
                              });
                            },
                            icon: Obx(
                                  () => IconTheme(
                                data: IconThemeData(
                                  color: _favoriteController
                                      .isFavorite(property.id)
                                      ? Colors.red
                                      : Colors.white70,
                                  size: 16.sp,
                                ),
                                child: FaIcon(
                                  _favoriteController.isFavorite(property.id)
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 1.h,
                  ),
                  // const Divider(),
                  SizedBox(
                    height: 1.h,
                  ),
                  MoreDetailsButton(
                    onPressed: () {
                      Get.to(() => PropertyDetails(
                        agentDetails: agentDetails,
                        propertyDetails: commercialProperty,
                      ));
                    },
                    label: "More Details",
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (property is IndustrialModel) {
      IndustrialModel industrialProperty = property;
      final List<String> imageList = industrialProperty.images;
      String price = formatPrice(property.price);
      return SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 1.h,
                  ),
                  Stack(children: [
                    Card(
                      color: Colors.white,
                      elevation: 0.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(1.h)),
                            child: ImageCarousel(
                              imageList: imageList,
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
                                  children: [
                                    Text(
                                      price,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87),
                                    ),
                                    SizedBox(
                                      width: 4.w,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1.2.w, vertical: 0.3.h),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.h)),
                                      ),
                                      child: Text(
                                        "For Sale",
                                        style: TextStyle(
                                          color: Color(0xFF80CBC4),
                                          fontSize: 8.sp,
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
                                  style: TextStyle(
                                      fontSize: 11.sp, color: Colors.grey[800]),
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.locationDot,
                                      size: 12.sp,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      "${property.address}, ${property.city}",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    CustomRow(
                                      icon: FontAwesomeIcons.stairs,
                                      text: industrialProperty.numOfFloors,
                                    ),
                                    SizedBox(
                                      width: 3.w,
                                    ),
                                    CustomRow(
                                      icon: FontAwesomeIcons.ruler,
                                      text: formatSquareMeters(
                                          industrialProperty.areaPerFloor),
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
                      left: 82.w,
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                _favoriteController
                                    .toggleFavoriteProduct(property.id);
                              });
                            },
                            icon: Obx(
                                  () => IconTheme(
                                data: IconThemeData(
                                  color: _favoriteController
                                      .isFavorite(property.id)
                                      ? Colors.red
                                      : Colors.white70,
                                  size: 16.sp,
                                ),
                                child: FaIcon(
                                  _favoriteController.isFavorite(property.id)
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),

                  SizedBox(
                    height: 1.h,
                  ),
                  // const Divider(),
                  SizedBox(
                    height: 1.h,
                  ),
                  MoreDetailsButton(
                    onPressed: () {
                      Get.to(() => PropertyDetails(
                        agentDetails: agentDetails,
                        propertyDetails: industrialProperty,
                      ));
                    },
                    label: "More Details",
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (property is LandModel) {
      LandModel landProperty = property;
      final List<String> imageList = landProperty.images;
      String price = formatPrice(property.price);
      return SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 1.h,
                  ),
                  Stack(children: [
                    Card(
                      color: Colors.white,
                      elevation: 0.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(1.h)),
                            child: ImageCarousel(
                              imageList: imageList,
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
                                  children: [
                                    Text(
                                      price,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87),
                                    ),
                                    SizedBox(
                                      width: 4.w,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 1.2.w, vertical: 0.3.h),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.h)),
                                      ),
                                      child: Text(
                                        "For Sale",
                                        style: TextStyle(
                                          color: Color(0xFF80CBC4),
                                          fontSize: 8.sp,
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
                                  style: TextStyle(
                                      fontSize: 11.sp, color: Colors.grey[800]),
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.locationDot,
                                      size: 12.sp,
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      "${property.address}, ${property.city}",
                                      style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 0.5.h,
                                ),
                                Row(
                                  children: [
                                    CustomRow(
                                      icon: FontAwesomeIcons.ruler,
                                      text: formatSquareMeters(
                                          landProperty.squareMeters),
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
                      left: 82.w,
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return IconButton(
                            onPressed: () {
                              setState(() {
                                _favoriteController
                                    .toggleFavoriteProduct(property.id);
                              });
                            },
                            icon: Obx(
                                  () => IconTheme(
                                data: IconThemeData(
                                  color: _favoriteController
                                      .isFavorite(property.id)
                                      ? Colors.red
                                      : Colors.white70,
                                  size: 16.sp,
                                ),
                                child: FaIcon(
                                  _favoriteController.isFavorite(property.id)
                                      ? FontAwesomeIcons.solidHeart
                                      : FontAwesomeIcons.heart,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 1.h,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  MoreDetailsButton(
                    onPressed: () {
                      Get.to(() => PropertyDetails(
                        agentDetails: agentDetails,
                        propertyDetails: landProperty,
                      ));
                    },
                    label: "More Details",
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const ListTile(
      title: Text('Unknown Property Type'),
    );
  }

  String formatPrice(String price) {
    double value = double.parse(price);
    final formatCurrency = NumberFormat("#,##0", "en_US");
    return 'K${formatCurrency.format(value)}';
  }

  String formatSquareMeters(String squareMeters) {
    return '${double.parse(squareMeters)} m²';
  }
}
