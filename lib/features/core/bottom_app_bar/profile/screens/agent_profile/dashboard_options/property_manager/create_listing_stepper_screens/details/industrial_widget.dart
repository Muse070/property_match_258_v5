import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/industrial_controller.dart';
import 'package:property_match_258_v5/widgets/agent_property_listing_widgets/property_type_option.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../widgets/agent_property_listing_widgets/currency_selection_widget.dart';

class IndustrialWidget extends StatefulWidget {
  final GlobalKey <FormState> formKey;
  const IndustrialWidget({
    super.key,
    required this.formKey,
  });

  @override
  State<IndustrialWidget> createState() => _IndustrialWidgetState();
}

class _IndustrialWidgetState extends State<IndustrialWidget> {


  final ListingController _listingController =
      Get.find<ListingController>();

  final IndustrialController _industrialController =
      Get.find<IndustrialController>();

  late Map<String, bool> _industrialAmenities = {
    'Security': false,
    'Fire Safety': false,
    'Electricity Supply': false,
    'Water Supply': false,
    'Canteen': false,
    'Wi-Fi': false,
    'Parking': false,
    "Nearby Public Transportation": false,
    'On-Site Cafeteria': false,
    'Nearby Restaurants': false,
  };

  final options = [
    'Manufacturing',
    'Storage',
    'Factory',
    'Distribution',
    'Warehouse',
    'Truck Terminal',
    'Flex Space',
  ];

  String _selectedOption = "";

  @override
  void initState() {

    if (_listingController.currentController.value is IndustrialController) {
      var controller = (_listingController.currentController.value as IndustrialController);
      _industrialAmenities = {
        'Security': controller.iAmenities.contains('Security'),
        'Fire Safety': controller.iAmenities.contains('Fire Safety'),
        'Electricity Supply': controller.iAmenities.contains('Electricity Supply'),
        'Water Supply': controller.iAmenities.contains('Water Supply'),
        'Canteen': controller.iAmenities.contains('Canteen'),
        'Wi-Fi': controller.iAmenities.contains('Wi-Fi'),
        'Parking': controller.iAmenities.contains('Parking'),
        "Nearby Public Transportation": controller.iAmenities.contains('Nearby Public Transportation'),
        'On-Site Cafeteria': controller.iAmenities.contains('On-Site Cafeteria'),
        'Nearby Restaurants': controller.iAmenities.contains('Nearby Restaurants'),
      };
    }

    _selectedOption = options[0];
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _industrialController.option = _selectedOption;
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
                          _listingController.currency.value = currency;                        },
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
              controller: _listingController.currentController.value is IndustrialController
                  ? (_listingController.currentController.value as IndustrialController).priceController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is IndustrialController) {
                  var controller = (_listingController.currentController.value as IndustrialController);
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
              controller: _listingController.currentController.value is IndustrialController
                  ? (_listingController.currentController.value as IndustrialController).numOfFloorsController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is IndustrialController) {
                  var controller = (_listingController.currentController.value as IndustrialController);
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
              controller: _listingController.currentController.value is IndustrialController
                  ? (_listingController.currentController.value as IndustrialController).totalAreaController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is IndustrialController) {
                  var controller = (_listingController.currentController.value as IndustrialController);
                  controller.updateTotalArea(text);
                }
              },                              decoration: InputDecoration(
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
              controller: _listingController.currentController.value is IndustrialController
                  ? (_listingController.currentController.value as IndustrialController).areaPerFloorController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is IndustrialController) {
                  var controller = (_listingController.currentController.value as IndustrialController);
                  controller.updateAreaPerFloor(text);
                }
              },
              decoration: InputDecoration(
                labelText: 'Area Per Floor',
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
              controller: _listingController.currentController.value is IndustrialController
                  ? (_listingController.currentController.value as IndustrialController).descriptionController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value is IndustrialController) {
                  var controller = (_listingController.currentController.value as IndustrialController);
                  controller.updateDescription(text);
                }
              },
              minLines: 3,
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
              children: _industrialAmenities.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: _industrialAmenities[key],
                  onChanged: (value) {
                    setState(() {
                      _industrialAmenities[key] = value!;
                      // Get the list of selected amenities
                      List<String> selectedAmenities =
                      _industrialAmenities.keys.where((k) => _industrialAmenities[k] ==
                          true).toList();
                      if (_listingController.currentController.value is IndustrialController) {
                        var controller = (_listingController.currentController.value as IndustrialController);
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
