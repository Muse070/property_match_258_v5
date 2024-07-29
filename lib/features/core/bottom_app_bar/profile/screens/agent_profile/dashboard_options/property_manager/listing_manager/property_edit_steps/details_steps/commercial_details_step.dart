import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/commercial_step_controller.dart';
import 'package:property_match_258_v5/model/property_models/commercial_property_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../../model/property_models/property_model.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/currency_selection_widget.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/property_type_option.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/radio_button.dart';
import '../../../../../../../controllers/edit_property_step_controllers/edit_property_controller.dart';
import '../../../../../../../controllers/property_type_controllers/listing_controller.dart';
import '../../../../../../../controllers/property_type_controllers/commercial_controller.dart';

class CommercialDetailsStep extends StatefulWidget {
  final PropertyModel property;

  const CommercialDetailsStep({super.key, required this.property});

  @override
  State<CommercialDetailsStep> createState() => _CommercialDetailsStepState();
}

class _CommercialDetailsStepState extends State<CommercialDetailsStep> {
  final ListingController _listingController =
  Get.find<ListingController>();

  late final CommercialStepController _commercialController;

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

  late final EditPropertyController _editPropertyController;

  @override
  void initState() {
    _selectedOption = options[0];
    super.initState();
    Get.put<EditPropertyController>(EditPropertyController(widget.property));

    if (widget.property is CommercialModel) {
      Get.put<CommercialStepController>(CommercialStepController(widget.property as CommercialModel));
    }

    _commercialController = Get.find<CommercialStepController>();

    _editPropertyController =
        Get.find<EditPropertyController>(); // Access it later
    _selectedOption = _editPropertyController.selectedPropertyOption.value;
    // ... other code

    _editPropertyController.updateCurrency(_commercialController.currency.value);


    // Check if current controller is CommercialStepController
    if (_editPropertyController.currentController.value
    is CommercialStepController) {
      var controller = _editPropertyController.currentController.value
      as CommercialStepController;

      // Create all amenities with initial value false
      _commercialAmenities = Map.fromIterable(_commercialAmenities.keys,
          key: (key) => key, value: (key) => false);

      // Set true for amenities in controller's mAmenities
      for (var amenity in controller.mAmenities) {
        if (_commercialAmenities.containsKey(amenity)) {
          _commercialAmenities[amenity] = true;
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (options.contains(_editPropertyController.selectedPropertyOption.value)){
      _selectedOption = _editPropertyController.selectedPropertyOption.value;
    } else {
      _selectedOption = options[0];
      _editPropertyController.selectedPropertyOption.value = _selectedOption;
    }
  }

  void _onContainerTap(String option) {
    setState(() {
      _selectedOption = option;
      _commercialController.updatePropertyOption(_selectedOption);
      // _editPropertyController.updateSelectedPropertyOption(_selectedOption);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      // key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            RadioButtonWidget(
              selectedStatus: _editPropertyController.forSaleOrRent,
              updateStatus: _editPropertyController.updateRentOrSale,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: options.expand((option) =>
                [
                  SelectableContainer(
                    option: option,
                    icon: Icons.cabin,
                    selectedOption: _selectedOption,
                    onContainerTap: _onContainerTap,
                  ),
                  SizedBox(
                    width: 2.h,
                  ),
                ]).toList()
                  ..removeLast(), // Remove the last SizedBox
              ),),
            SizedBox(
              height: 2.h,
            ),
            Card(
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
                      initialCurrency: _commercialController.currency.value,
                      onCurrencySelected: (String currency) {
                        // Handle the selected currency here
                        _commercialController.currency.value = currency;
                        _editPropertyController.currency.value = currency;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 1.5.h,
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
              controller: _editPropertyController.currentController
                  .value is CommercialStepController
                  ? (_editPropertyController.currentController
                  .value as CommercialStepController).priceController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController
                    .value is CommercialStepController) {
                  var controller = (_editPropertyController.currentController
                      .value as CommercialStepController);
                  controller.price.value;
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
              controller: _editPropertyController.currentController
                  .value is CommercialStepController
                  ? (_editPropertyController.currentController
                  .value as CommercialStepController).numFloorsController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController
                    .value is CommercialStepController) {
                  var controller = (_editPropertyController.currentController
                      .value as CommercialStepController);
                  controller.numFloors.value;
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
              controller: _editPropertyController.currentController
                  .value is CommercialStepController
                  ? (_editPropertyController.currentController
                  .value as CommercialStepController).squareMetersController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController
                    .value is CommercialStepController) {
                  var controller = (_editPropertyController.currentController
                      .value as CommercialStepController);
                  controller.squareMeters.value;
                }
              }, decoration: InputDecoration(
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
              controller: _editPropertyController.currentController
                  .value is CommercialStepController
                  ? (_editPropertyController.currentController
                  .value as CommercialStepController).descriptionController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController
                    .value is CommercialStepController) {
                  var controller = (_editPropertyController.currentController
                      .value as CommercialStepController);
                  controller.description.value;
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
              children: _commercialAmenities.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: _commercialAmenities[key],
                  onChanged: (value) {
                    setState(() {
                      _commercialAmenities[key] = value!;
                      // Get the list of selected amenities
                      List<String> selectedAmenities =
                      _commercialAmenities.keys.where((k) =>
                      _commercialAmenities[k] ==
                          true).toList();
                      if (_editPropertyController.currentController
                          .value is CommercialStepController) {
                        var controller = (_listingController.currentController
                            .value as CommercialStepController);
                        // controller.updateAmenities(selectedAmenities);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(
              height: 2.h,
            ),
          ],
        ),
      ),
    );
  }
}
