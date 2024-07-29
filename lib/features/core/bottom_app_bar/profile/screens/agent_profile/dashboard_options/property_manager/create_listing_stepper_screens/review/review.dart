import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/commercial_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/industrial_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/land_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/residential_controllers.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../widgets/agent_property_listing_widgets/custom_marker.dart';

class ReviewScreen extends StatefulWidget {
  final ValueNotifier<bool> updateNotifier;
  const ReviewScreen({super.key, required this.updateNotifier});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ListingController _listingController = Get.find<ListingController>();

  final Completer<PDFViewController> _controller =
  Completer<PDFViewController>();

  final GlobalKey _markerIconKey = GlobalKey();

  GoogleMapController? mapController;

  BitmapDescriptor? customIcon;

  bool isMarkerOffScreen = false;

  List<Marker> markers = [];

  int? pages;
  bool isReady = false;

  // double? latitude;
  // double? longitude;

  RxString priceTag = "".obs;

  bool isDocListEmpty = true;

  StreamSubscription? latitudeSubscription;
  StreamSubscription? longitudeSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      WidgetsBinding.instance!.addPostFrameCallback((_) async {
        createCustomMarker(context);
      });
    });
  }

  @override
  void dispose() {
    latitudeSubscription?.cancel();
    longitudeSubscription?.cancel();
    super.dispose();
  }

  String formatPrice(String price) {
    double value = double.parse(price);
    if (value >= 1000000000) {
      return 'ZMW ${(value / 1000000000).toStringAsFixed(2)}B';
    } else if (value >= 1000000) {
      return 'ZMW ${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return 'ZMW ${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return 'ZMW $value';
    }
  }

  String formatSquareMeters(String squareMeters) {
    return '${double.parse(squareMeters)} m²';
  }

  Widget residentialColumn() {
    var controller = _listingController.currentController.value as ResidentialController;
    priceTag = controller.price;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.description.value,
          style: const TextStyle(
              color: Colors.black
          ),
        ),
        SizedBox(height: 1.5.h,),
        Wrap(
          spacing: 3.5,
          runSpacing: 0.5,
          children: [
            for (var text in controller.mAmenities) ...[
              Chip(
                label: Text(
                  text,
                  style: TextStyle(
                    fontSize: 8.sp
                  ),
                ),              )
            ]
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
                formatPrice(controller.price.value),
                style: TextStyle(
                    color: Color(0xFF005555),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500
                ),
              ),
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                      color: Color(0xFF005555),
                      size: 12.sp
                  ),
                  child: const FaIcon(FontAwesomeIcons.bed),
                ),
                SizedBox(width: 2.w,),
                Text(
                  controller.numBedrooms.value,
                  style: TextStyle(
                      color: Color(0xFF005555),
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                      color: Color(0xFF005555),
                      size: 12.sp
                  ),
                  child: const FaIcon(FontAwesomeIcons.bath),
                ),
                SizedBox(width: 2.w,),
                Text(
                  controller.numBathrooms.value,
                  style: TextStyle(
                      color: Color(0xFF005555),
                    fontSize: 10.sp
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                      color: Color(0xFF005555),
                      size: 12.sp
                  ),
                  child: const FaIcon(FontAwesomeIcons.ruler),
                ),
                SizedBox(width: 2.w,),
                Text(
                  formatSquareMeters(controller.squareMeters.value),
                  style: TextStyle(
                      color: Color(0xFF005555),
                    fontSize: 10.sp
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget commercialColumn() {
    var controller = _listingController.currentController.value as CommercialController;
    priceTag = controller.cPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.cDescription.value,
          style: const TextStyle(
              color: Colors.black
          ),
        ),
        SizedBox(height: 1.5.h,),
        Wrap(
          spacing: 3.5,
          runSpacing: 0.5,
          children: [
            for (var text in controller.cAmenities) ...[
              Chip(
                label: Text(
                  text,
                  style: TextStyle(
                    fontSize: 8.sp
                  ),
                ),              )
            ]
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              formatPrice(controller.cPrice.value),
              style: TextStyle(
                  color: Color(0xFF005555),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500
              ),
            ),
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                      color: Color(0xFF005555),
                      size: 12.sp
                  ),
                  child: const FaIcon(FontAwesomeIcons.stairs),
                ),
                SizedBox(width: 2.w,),
                Text(
                  controller.cNumOfFloors.value,
                  style: TextStyle(
                      color: Color(0xFF005555),
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                      color: Color(0xFF005555),
                      size: 12.sp
                  ),
                  child: const FaIcon(FontAwesomeIcons.ruler),
                ),
                SizedBox(width: 2.w,),
                Text(
                  formatSquareMeters(controller.cSquareMeters.value),
                  style: TextStyle(
                      color: Color(0xFF005555),
                      fontSize: 10.sp
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget industrialColumn() {
    var controller = _listingController.currentController.value as IndustrialController;
    priceTag = controller.iPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.iDescription.value,
          style: const TextStyle(
              color: Colors.black
          ),
        ),
        SizedBox(height: 1.5.h,),
        Wrap(
          spacing: 3.5,
          runSpacing: 0.5,
          children: [
            for (var text in controller.iAmenities) ...[
              Chip(
                label: Text(
                  text,
                  style: TextStyle(
                    fontSize: 8.sp
                  ),
                ),              )
            ]
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              controller.iPrice.value,
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500
              ),
            ),
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                      size: 12.sp
                  ),
                  child: const FaIcon(FontAwesomeIcons.stairs),
                ),
                SizedBox(width: 2.w,),
                Text(
                  controller.iNumOfFloors.value,
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 10.sp
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                      size: 12.sp
                  ),
                  child: const FaIcon(FontAwesomeIcons.rulerCombined),
                ),
                SizedBox(width: 2.w,),
                Text(
                  controller.iAreaPerFloor.value,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10.sp
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                      size: 12.sp
                  ),
                  child: const FaIcon(FontAwesomeIcons.ruler),
                ),
                SizedBox(width: 2.w,),
                Text(
                  controller.iTotalArea.value,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 10.sp
                  ),
                ),
              ],
            ),
          ],
        ),

      ],
    );
  }

  Widget landColumn() {
    var controller = _listingController.currentController.value as LandController;
    priceTag = controller.lPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.lDescription.value,
          style: const TextStyle(
              color: Colors.black
          ),
        ),
        SizedBox(height: 1.5.h,),
        Wrap(
          spacing: 3.5,
          runSpacing: 0.5,
          children: [
            for (var text in controller.lAmenities) ...[
              Chip(
                label: Text(
                    text,
                  style: TextStyle(
                    fontSize: 8.sp
                  ),
                ),
              )
            ]
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              formatPrice(controller.lPrice.value),
              style: TextStyle(
                  color: Color(0xFF005555),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500
              ),
            ),
            Row(
              children: [
                IconTheme(
                  data: IconThemeData(
                      color: Color(0xFF005555),
                      size: 14.sp
                  ),
                  child: const FaIcon(FontAwesomeIcons.ruler),
                ),
                SizedBox(width: 2.w,),
                Text(
                  formatSquareMeters(controller.lSquareMeters.value),
                  style: TextStyle(
                      color: Color(0xFF005555),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget propertyTypeSelector() {
    return Obx(() {
      if (_listingController.currentController.value is ResidentialController) {
        return residentialColumn();
      } else if (_listingController.currentController.value is CommercialController) {
        return commercialColumn();  // Return an empty Container (or some other widget) by default
      } else if (_listingController.currentController.value is IndustrialController) {
        return industrialColumn();
      } else if (_listingController.currentController.value is LandController) {
        return landColumn();
      } else {
        return Container();
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    print("Marker list is: $markers");
  }

  @override
  void didUpdateWidget(covariant ReviewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    createCustomMarker(context);
  }

  Future<void> createCustomMarker(BuildContext context) async {
    RenderRepaintBoundary boundary = _markerIconKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    await Future.delayed(Duration(milliseconds: 20));
    ui.Image image = await boundary.toImage(pixelRatio: 1.7);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    customIcon = BitmapDescriptor.fromBytes(pngBytes);

    setState(() {
      isMarkerOffScreen = true;
    });

    setMarker();
  }

  void setMarker() {
    print("setMarker called");

    try {
      Marker myMarker = Marker(
        markerId: MarkerId(_listingController.addressParts.value),
        position: LatLng(
            _listingController.latitude.value,
            _listingController.longitude.value
        ),
        infoWindow: InfoWindow(
          title: _listingController.addressParts.value,
        ),
        icon: customIcon!,
      );

      setState(() {
        markers.clear();
        markers.add(myMarker);
      });

      print("Markers list is: $markers");
    } catch (e) {
      print("Exception in setMarker: $e");
    }
  }

  Widget _googleMap() {

    return Obx(
        () => Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                  _listingController.latitude.value,
                  _listingController.longitude.value
              ),
              zoom: 18,
            ),
            // myLocationEnabled: true,
            mapType: MapType.hybrid,
            markers: Set<Marker>.of(markers),
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
          ),
          Transform.translate(
            offset: Offset(
              -MediaQuery.of(context).size.width * 2,
              -MediaQuery.of(context).size.height * 2,
            ),
            child: RepaintBoundary(
              key: _markerIconKey,
              child: CustomMarker(price: priceTag,),
            ),
          ),
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: widget.updateNotifier,
        builder: (context, value, child) {
          if (value) {
            WidgetsBinding.instance!.addPostFrameCallback((_) async {
              await Future.delayed(const Duration(milliseconds: 20));
              widget.updateNotifier.value = false;
            });
          }
          return Container(
            height: 70.h,
            width: 100.w,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Obx(() =>
                      Text(
                        "Property ${_listingController.forSaleOrRent.value}",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                  ),
                  SizedBox(height: 2.h,),

                  // Details Card
                  Card(
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() =>
                              Text(
                                "${_listingController.selectedPropertyType
                                    .value}: "
                                    "${_listingController.selectedPropertyOption
                                    .value}",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500
                                ),
                              )),
                          const Divider(),
                          SizedBox(height: 1.15.h,),
                          propertyTypeSelector(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h,),

                  // Location
                  Text(
                    "Location",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  // Google Map
                  SizedBox(
                    height: 30.h,
                    width: 100.w,
                    child: Card(
                      child: _googleMap(),
                    ),
                  ),
                  SizedBox(height: 2.h,),
                  // Address card
                  Card(
                    elevation: 2,
                    color: Colors.white,
                    child: Container(
                      width: 100.w,
                      padding: EdgeInsets.all(2.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconTheme(
                            data: IconThemeData(
                                color: Color(0xFF005555),
                                size: 14.sp
                            ),
                            child: const FaIcon(FontAwesomeIcons.locationDot),
                          ),
                          SizedBox(width: 3.w,),
                          Flexible(
                            child: Obx(() =>
                                Text(
                                  "${_listingController.addressParts.value}, "
                                      "${_listingController.city.value}, "
                                      "${_listingController.country.value}",
                                  softWrap: true,
                                ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h,),

                  // Images upload
                  Text(
                    "Images",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 2.h,),
                  Obx(() =>
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i <
                                _listingController.imageListStrDyn.length; i++) ...[
                              SizedBox(
                                child: Image.memory(
                                  _listingController.imageListStrDyn.map((fileMap) =>
                                  fileMap['bytes'] as Uint8List).toList()[i],
                                  width: 16.h,
                                  height: 16.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (i != _listingController.imageListStrDyn.length - 1)
                                SizedBox(
                                  width: 1.5.w,
                                )
                            ]
                          ],
                        ),
                      ),
                  ),
                  SizedBox(height: 2.h,),

                  // Documents
                  Text(
                    "Documents",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  SizedBox(height: 2.h,),
                  (_listingController.docPathList.isNotEmpty) ? Obx(() =>
                    SizedBox(
                        height: 20.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _listingController.docPathList.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 30.w,
                              child: PDFView(
                                filePath: _listingController.docPathList[index],
                                enableSwipe: true,
                                swipeHorizontal: true,
                                autoSpacing: true,
                                pageFling: false,
                                onRender: (_pages) {
                                  setState(() {
                                    pages = _pages;
                                    isReady = true;
                                  });
                                },
                                onError: (error) {
                                  print(error.toString());
                                },
                                onPageError: (page, error) {
                                  print('$page: ${error.toString()}');
                                },
                                onViewCreated: (
                                    PDFViewController pdfViewController) {
                                  _controller.complete(pdfViewController);
                                },
                                onPageChanged: (int? page, int? total) {
                                  print('page change: $page/$total');
                                },
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            // Don't add a separator after the last item
                            if (index == _listingController.docPathList!.length -
                                1) {
                              return const SizedBox.shrink();
                            }
                            // Add a SizedBox with your desired width for other items
                            return SizedBox(width: 2.w);
                          },
                        ),
                      ),
                  ) :
                  Card(
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      width: 100.w,
                      child: Column(
                        children: [
                          SizedBox(height: 1.15.h),
                          CircleAvatar(
                            radius: 10.w,
                            backgroundColor: Colors.white,
                            child: IconTheme(
                              data: IconThemeData(
                                  color: Color(0xFF005555),
                                  size: 28.sp
                              ),
                              child: const FaIcon(FontAwesomeIcons.xmark),
                            ),
                          ),
                          SizedBox(height: 2.h,),
                          Text(
                            "Document list is empty",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 1.15.h)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h,),
                ],
              ),
            ),
          );
        }
      );
    }
  }

