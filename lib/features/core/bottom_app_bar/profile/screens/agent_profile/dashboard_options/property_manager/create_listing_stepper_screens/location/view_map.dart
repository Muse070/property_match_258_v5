import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../widgets/agent_property_listing_widgets/custom_marker.dart';
import '../../../../../../controllers/property_type_controllers/listing_controller.dart';
import '../../../../../../controllers/property_type_controllers/commercial_controller.dart';
import '../../../../../../controllers/property_type_controllers/industrial_controller.dart';
import '../../../../../../controllers/property_type_controllers/land_controller.dart';
import '../../../../../../controllers/property_type_controllers/residential_controllers.dart';

class ViewMap extends StatefulWidget {
  final TextEditingController country;
  final TextEditingController city;
  final TextEditingController propertyAddress;
  late List<Marker> myMarkers;

  ViewMap({
    super.key,
    required this.myMarkers,
    required this.country,
    required this.city,
    required this.propertyAddress,
  });

  @override
  State<ViewMap> createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  final GlobalKey _markerIconKey = GlobalKey();

  late Marker marker;
  final _locationController = Get.find<ListingController>();
  final _userRepo = Get.find<UserRepository>();

  bool isMarkerOffScreen = false;

  double lat = 0.0;
  double lng = 0.0;

  RxString priceTag = "".obs;

  BitmapDescriptor? customIcon;

  final Completer<GoogleMapController> _mapController = Completer();



  @override
  void initState() {
    super.initState();
    setPriceTag();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _userRepo.getLocation().then((position) {
        lat = position.latitude;
        lng = position.longitude;
        print("Current location is: $lat $lng");
      });

      WidgetsBinding.instance
          .addPostFrameCallback((_) async => await createCustomMarker(context));
    });
  }

  void setPriceTag() {
    if (_locationController.currentController.value is ResidentialController) {
      var controller =
          _locationController.currentController.value as ResidentialController;
      priceTag = controller.price;
    } else if (_locationController.currentController.value
        is CommercialController) {
      var controller =
          _locationController.currentController.value as CommercialController;
      priceTag = controller.cPrice;
    } else if (_locationController.currentController.value
        is IndustrialController) {
      var controller =
          _locationController.currentController.value as IndustrialController;
      priceTag = controller.iPrice;
    } else if (_locationController.currentController.value is LandController) {
      var controller =
          _locationController.currentController.value as LandController;
      priceTag = controller.lPrice;
    } else {
      priceTag.value = "0";
    }
  }

  Marker _getMarker(double lat, double lng) {
    return Marker(
      markerId: MarkerId(lat.toString()),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(
        title: widget.propertyAddress.text,
      ),
      draggable: true,
      onDragEnd: (newPosition) {
        _locationController.updateLocation(
            newPosition.latitude, newPosition.longitude);
        print(
            "new position is: ${_locationController.latitude}, ${_locationController.longitude}"
        );
      },
      icon: customIcon ?? BitmapDescriptor.defaultMarker, // Use null-coalescing operator
    );
  }

  Future<void> setLatLng() async {
    final value = await getUserLocation();

    // Check if location exists in the controller
    if (_locationController.latitude != 0.0 &&
        _locationController.longitude != 0.0) {
      lat = _locationController.latitude.value;
      lng = _locationController.longitude.value;
    } else if (widget.propertyAddress.text.isNotEmpty ||
        widget.country.text.isNotEmpty ||
        widget.city.text.isNotEmpty) {
      // If not, check if location can be created from the search screen
      List<Location> location =
          await locationFromAddress("${widget.country.text}, "
              "${widget.city.text}, ${widget.propertyAddress.text}");
      lat = location.last.latitude;
      lng = location.last.longitude;
    } else {
      // If neither exists, let the user create a marker on the map
      // You can set default values here
      lat = value.latitude;
      lng = value.longitude;
    }

    print("${value.longitude}");

    updateMarker(lat, lng);
    _locationController.updateLocation(lat, lng);
  }
  void updateMarker(double lat, double lng) {
    Marker newMarker = _getMarker(lat, lng);
    if (mounted) {
      setState(() {
        widget.myMarkers = [newMarker];
      });
    }
  }

  Future<Position> getUserLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print('error: $error');
    });

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() async {
      await setLatLng();
    });
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      leading: IconButton(
        icon: IconTheme(
          data: IconThemeData(
            size: 3.h,
            color: Colors.black87,
          ),
          child: const FaIcon(FontAwesomeIcons.angleLeft),
        ),
        onPressed: () {
          Get.back();
        },
      ),
      title: const Text("Map"),
      actions: [
        Ink(
          height: 2.5.h,
          width: 6.5.w,
          decoration: const ShapeDecoration(
            color: Colors.transparent,
            // Change this to your desired background color
            shape: CircleBorder(
              side: BorderSide(
                color: Colors.black, // Change this to your desired border color
                width: 1, // Change this to your desired border width
              ),
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.all(0.5.w),
            // Adjust this value to reduce the size of the circle
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('How to Set Location'),
                    content: const Text(
                        '1. Enter the full address of the property. If recognized, the location will be pinned on the map when you click \'View Full Map\'.\n'
                        '2. If the address doesn\'t exist on Google Maps, manually set the location. Open the full map view and long press on the desired location.\n'
                        '3. A pin will appear where you pressed. Adjust the location by dragging this pin.\n'
                        '4. As you type in the search bar, address suggestions will appear. Select the correct one and a pin will appear on the map representing your location.\n'
                        '5. To remove a pin from the map, ...\n'
                        '6. Once satisfied with the location, click \'Continue\'.'),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(
              Icons.question_mark_outlined,
              size: 10.sp,
            ),
          ),
        ),
        SizedBox(
          width: 1.15.w,
        )
      ],
      // backgroundColor: Colors.white70,
    );
  }

  Future<void> createCustomMarker(BuildContext context) async {
    RenderRepaintBoundary boundary = _markerIconKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 2.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    customIcon = BitmapDescriptor.fromBytes(pngBytes);

    setState(() {
      isMarkerOffScreen = true;
      updateMarker(lat, lng); // Move marker creation here
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _appBar(),
        body: Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, lng),
              zoom: 18,
            ),
            myLocationEnabled: true,
            mapType: MapType.hybrid,
            markers: Set<Marker>.of(widget.myMarkers),
            zoomControlsEnabled: false,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            onMapCreated: (GoogleMapController mapController) async {
              // packData();
              await setLatLng();
              print("Current positions is: $lat, $lng");
              mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      lat,
                      lng,
                    ),
                    zoom: 18.0,
                  ),
                ),
              );
            },
            onTap: (LatLng latLng) {
              widget.myMarkers.clear();
              setState(() {
                marker = Marker(
                    markerId: MarkerId(widget.propertyAddress.text),
                    infoWindow: InfoWindow(title: widget.propertyAddress.text),
                    position: latLng,
                    draggable: true,
                    onDragEnd: (newPosition) {
                      _locationController.updateLocation(
                          newPosition.latitude, newPosition.longitude);
                    },
                  icon: customIcon ?? BitmapDescriptor.defaultMarker, // Use null-coalescing operator
                );
                widget.myMarkers.add(marker);
              });
              _locationController.updateLocation(
                  latLng.latitude, latLng.longitude);
            },
            onLongPress: (LatLng latLng) {
              setState(() {
                widget.myMarkers.removeWhere(
                    (m) => m.markerId.value == widget.propertyAddress.text);
              });
            },
          ),
          Transform.translate(
            offset: Offset(
              -MediaQuery.of(context).size.width * 2,
              -MediaQuery.of(context).size.height * 2,
            ),
            child: RepaintBoundary(
              key: _markerIconKey,
              child: CustomMarker(
                price: priceTag,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
