import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/create_listing_stepper_screens/location/view_map.dart';
import 'package:sizer/sizer.dart';

import 'search_screen.dart';

class LocationWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const LocationWidget({super.key, required this.formKey});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  final _locationController = Get.find<ListingController>();
  final Completer<GoogleMapController> _mapController = Completer();

  final List<Marker> myMarkers = [];

  late TextEditingController _country;
  late TextEditingController _city;
  late TextEditingController _propertyAddress;

  @override
  void initState() {
    super.initState();
      _propertyAddress = TextEditingController();
      _city = TextEditingController();
      _country = TextEditingController();
  }

  @override
  void dispose() {
    _propertyAddress.dispose();
    _city.dispose();
    _country.dispose();
    if (_mapController.isCompleted) {
      _mapController.future.then((controller) => controller.dispose());
    }
    // _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _propertyAddress.text = _locationController.addressParts.value;
    _city.text = _locationController.city.value;
    _country.text = _locationController.country.value;

    return Form(
      key: widget.formKey,
      child: SizedBox(
        height: 70.h,
        width: 100.w,
        child: SingleChildScrollView(
          child: GetBuilder<ListingController>(
            init: ListingController(),
            builder: (controller) {
              return Column(
                children: [
                  _header()
,                 const Divider(),
                  SizedBox(
                    height: 2.h,
                  ),
                  _buildTextField(
                    controller: _propertyAddress,
                    labelText: 'Address',
                    onChanged: (value) {
                      controller.addressParts.value = value;
                      controller.update();
                    },
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  _buildTextField(
                    controller: _city,
                    labelText: 'City',
                    onChanged: (value) {
                      controller.city.value = value;
                      controller.update();
                    },
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  _buildTextField(
                    controller: _country,
                    labelText: 'Country',
                    onChanged: (value) {
                      controller.country.value = value;
                      controller.update();
                    },
                  ),
                  SizedBox(
                    height: 2.h,
                  ),
                  _buildElevatedButton(),
                  SizedBox(
                    height: 1.h,
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        helperText: controller.text.isEmpty ? 'This field is required' : null,
        helperStyle: const TextStyle(color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.w)),
        ),
      ),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }

  ElevatedButton _buildElevatedButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: const BorderSide(color: Colors.black),
          ),
        ),
      ),
      onPressed: () async {
        Get.to(() => ViewMap(
          myMarkers: myMarkers,
          country: _country,
          city: _city,
          propertyAddress: _propertyAddress,
        ));
      },
      child: const Text("View Full Map"),
    );
  }

  Widget _header() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Set Address",
            style: TextStyle(fontSize: 14.sp),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Get.to(() => const SearchScreen());
                },
                icon: const Icon(Icons.search),
              ),
              SizedBox(
                width: 1.15.w,
              ),
              Ink(
                height: 2.5.h,
                width: 6.5.w,
                decoration: const ShapeDecoration(
                  color: Colors.transparent,
                  // Change this to your desired background color
                  shape: CircleBorder(
                    side: BorderSide(
                      color: Colors.black,
                      // Change this to your desired border color
                      width:
                      1, // Change this to your desired border width
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
            ],
          )
        ],
      ),
    );
  }

}
