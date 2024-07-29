import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/land_controller.dart';
import 'package:property_match_258_v5/widgets/agent_property_listing_widgets/property_type_option.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../widgets/agent_property_listing_widgets/currency_selection_widget.dart';
import '../../../../../../../../../../widgets/agent_property_listing_widgets/furnished_widget.dart';

class LandWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const LandWidget({
    super.key,
    required this.formKey,
  });

  @override
  State<LandWidget> createState() => _LandWidgetState();
}

class _LandWidgetState extends State<LandWidget> {

  final ListingController _listingController =
      Get.find<ListingController>();

  final LandController _landController =
      Get.find<LandController>();

  String _selectedOption = "";

  late Map<String, bool> _landAmenities = {
    'Fencing/ Boundaries': false,
    'Driveways/ Roads': false,
    'Gates/ Security': false,
    'Water Supply': false,
    'Electricity Supply': false,
    'Parking': false,
    "Nearby Public Transportation": false,
    'Nearby Restaurants': false,
  };

  final options = [
    'Residential',
    'Commercial',
    'Industrial',
    'Agricultural',
    'Raw Land',
    'Development',
  ];

  @override
  void initState() {
    super.initState();
    if (_listingController.currentController.value is LandController) {
      var controller = (_listingController.currentController
          .value as LandController);
      _landAmenities = {
        'Fencing/ Boundaries': controller.lAmenities.contains('Fencing/ Boundaries'),
        'Driveways/ Roads': controller.lAmenities.contains('Driveways/ Roads'),
        'Gates/ Security': controller.lAmenities.contains('Gates/ Security'),
        'Water Supply': controller.lAmenities.contains('Water Supply'),
        'Electricity Supply': controller.lAmenities.contains('Electricity Supply'),
        'Parking': controller.lAmenities.contains('Parking'),
        "Nearby Public Transportation": controller.lAmenities.contains('Nearby Public Transportation'),
        'Nearby Restaurants': controller.lAmenities.contains('Nearby Restaurants'),
      };
    }
    _selectedOption = options[0];
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _landController.option.value = options[0];
      _listingController.updateSelectedPropertyOption(_selectedOption);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (options.contains(_listingController.selectedPropertyOption.value)){
      _selectedOption = _listingController.selectedPropertyOption.value;
    } else {
     _selectedOption = options[0];
     _listingController.selectedPropertyOption.value = _selectedOption;
    }
  }


  void _onContainerTap(String option) {
    setState(() {
      _selectedOption = option;
      _listingController.updateSelectedPropertyOption(_selectedOption);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: options.expand((option) => [
                  SelectableContainer(
                    option: option,
                    icon: Icons.cabin,
                    selectedOption: _selectedOption,
                    onContainerTap: _onContainerTap,
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                ]).toList()..removeLast(),  // Remove the last SizedBox
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            SizedBox(
              width: 100.w,
              child: Card(
                elevation: 0.8,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align labels to the start
                    children: [
                      Text(
                        "Currency:",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      CurrencySelectionWidget(
                        initialCurrency: _listingController.currency.value,
                        onCurrencySelected: (String currency) {
                          // Handle the selected currency here
                          _listingController.currency.value = currency;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 1.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Details",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            TextFormField(
              controller: _listingController.currentController.value is LandController
                  ? (_listingController.currentController.value as LandController).priceController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is LandController) {
                  var controller = (_listingController.currentController.value as LandController);
                  controller.updatePrice(text);
                }
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
            ),
            SizedBox(
              height: 2.h,
            ),
            TextFormField(
              controller: _listingController.currentController.value is LandController
                  ? (_listingController.currentController.value as LandController).squareMetersController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is LandController) {
                  var controller = (_listingController.currentController.value as LandController);
                  controller.updateSquareMeters(text);
                }
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total Area',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
            ),
            SizedBox(
              height: 2.h,
            ),
            TextFormField(
              controller: _listingController.currentController.value is LandController
                  ? (_listingController.currentController.value as LandController).descriptionController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is LandController) {
                  var controller = (_listingController.currentController.value as LandController);
                  controller.updateDescription(text);
                }
              },
              minLines: 3,
              maxLines: 5,
              style: TextStyle(fontSize: 12.sp),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText:
                'Describe unique features not listed. \nWhy might someone love this property?',
                contentPadding: EdgeInsets.all(3.w), // Change as needed
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                return null;
              },
            ),
            SizedBox(
              height: 2.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Amenities",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
              ),
            ),
            Column(
              children: _landAmenities.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: _landAmenities[key],
                  onChanged: (value) {
                    setState(() {
                      _landAmenities[key] = value!;
                      // Get the list of selected amenities
                      List<String> selectedAmenities =
                      _landAmenities.keys.where((k) => _landAmenities[k] ==
                          true).toList();
                      if (_listingController.currentController.value is LandController) {
                        var controller = (_listingController.currentController.value as LandController);
                        controller.updateAmenities(selectedAmenities);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
