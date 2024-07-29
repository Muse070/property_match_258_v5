import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/commercial_controller.dart';
import 'package:property_match_258_v5/widgets/agent_property_listing_widgets/property_type_option.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../widgets/agent_property_listing_widgets/currency_selection_widget.dart';
import '../../../../../../controllers/property_type_controllers/listing_controller.dart';

class CommercialWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const CommercialWidget({
    super.key,
    required this.formKey,
  });

  @override
  State<CommercialWidget> createState() => _CommercialWidgetState();
}

class _CommercialWidgetState extends State<CommercialWidget> {

  final ListingController _listingController =
  Get.find<ListingController>();

  final CommercialController _commercialController =
  Get.find<CommercialController>();

  final options = [
    'Office Space',
    'Retail',
    'Hotel',
    'Resort',
    'Multi Family',
    'Mixed Use',
  ];

  String _selectedOption = "";

  late Map<String, bool> _commercialAmenities = {
    'Conference Facilities': false,
    'Wi-Fi': false,
    'Parking': false,
    "Nearby Public Transportation": false,
    'On-Site Cafeteria': false,
    'Nearby Restaurants': false,
    'Fitness Center': false,
    'Outdoor scenery': false,
  };

  @override
  void initState() {

    if (_listingController.currentController.value is CommercialController) {
      var controller = (_listingController.currentController.value as CommercialController);
      _commercialAmenities = {
        'Conference Facilities': controller.cAmenities.contains('Conference Facilities'),
        'Wi-Fi': controller.cAmenities.contains('Wi-Fi'),
        'Parking': controller.cAmenities.contains('Parking'),
        "Nearby Public Transportation": controller.cAmenities.contains('Nearby Public Transportation'),
        'On-Site Cafeteria': controller.cAmenities.contains('On-Site Cafeteria'),
        'Nearby Restaurants': controller.cAmenities.contains('Nearby Restaurants'),
        'Fitness Center': controller.cAmenities.contains('Fitness Center'),
        'Outdoor scenery': controller.cAmenities.contains('Outdoor scenery'),
      };
    }

    _selectedOption = options[0];
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _commercialController.option.value = options[0];
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
                children: options.expand((option) => [
                  SelectableContainer(
                    option: option,
                    icon: Icons.cabin,
                    selectedOption: _selectedOption,
                    onContainerTap: _onContainerTap,
                  ),
                  SizedBox(
                    width: 2.h,
                  ),
                ]).toList()..removeLast(),  // Remove the last SizedBox
              ),          ),
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
              controller: _listingController.currentController.value is CommercialController
                  ? (_listingController.currentController.value as CommercialController).priceController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is CommercialController) {
                  var controller = (_listingController.currentController.value as CommercialController);
                  controller.updatePrice(text);
                }
              },
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
              controller: _listingController.currentController.value is CommercialController
                  ? (_listingController.currentController.value as CommercialController).numOfFloorsController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is CommercialController) {
                  var controller = (_listingController.currentController.value as CommercialController);
                  controller.updateNumOfFloors(text);
                }
              },
              decoration: InputDecoration(
                labelText: 'Number of Floors',
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
              controller: _listingController.currentController.value is CommercialController
                  ? (_listingController.currentController.value as CommercialController).squareMetersController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is CommercialController) {
                  var controller = (_listingController.currentController.value as CommercialController);
                  controller.updateSquareMeters(text);
                }
              },               decoration: InputDecoration(
                labelText: 'Square Meters',
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
              controller: _listingController.currentController.value is CommercialController
                  ? (_listingController.currentController.value as CommercialController).descriptionController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is CommercialController) {
                  var controller = (_listingController.currentController.value as CommercialController);
                  controller.updateDescription(text);
                }
              },               minLines: 3,
              maxLines: 5,
              style: TextStyle(fontSize: 12.sp),
              // Change as needed
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
              children: _commercialAmenities.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: _commercialAmenities[key],
                  onChanged: (value) {
                    setState(() {
                      _commercialAmenities[key] = value!;
                      // Get the list of selected amenities
                      List<String> selectedAmenities =
                      _commercialAmenities.keys.where((k) => _commercialAmenities[k] ==
                          true).toList();
                      if (_listingController.currentController.value is CommercialController) {
                        var controller = (_listingController.currentController.value as CommercialController);
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
