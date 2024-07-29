import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_property_step_controllers/land_step_controller.dart';
import 'package:property_match_258_v5/model/property_models/land_property_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../../model/property_models/property_model.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/currency_selection_widget.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/property_type_option.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/radio_button.dart';
import '../../../../../../../controllers/edit_property_step_controllers/edit_property_controller.dart';
import '../../../../../../../controllers/property_type_controllers/listing_controller.dart';
import '../../../../../../../controllers/property_type_controllers/land_controller.dart';

class LandDetailsStep extends StatefulWidget {
  final PropertyModel property;

  const LandDetailsStep({super.key, required this.property});

  @override
  State<LandDetailsStep> createState() => _LandDetailsStepState();
}

class _LandDetailsStepState extends State<LandDetailsStep> {

  RxString _selectedOption = "".obs;

  late final LandStepController _landStepController;


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

  late final EditPropertyController _editPropertyController;

  @override
  void initState() {
    super.initState();
    Get.put<EditPropertyController>(EditPropertyController(widget.property));

    if (widget.property is LandModel) {
      Get.put<LandStepController>(LandStepController(widget.property as LandModel));
    } else {
      // Handle the case where widget.property is not a LandModel
      print("Error: Invalid property type for editing.");
      // You might want to navigate back or display an error message here.
    }

    _editPropertyController =
        Get.find<EditPropertyController>(); // Access it later

    _landStepController = Get.find<LandStepController>();
    _selectedOption.value = _editPropertyController.selectedPropertyOption.value;

    _editPropertyController.updateCurrency(_landStepController.currency.value);

    if (_editPropertyController.currentController
        .value is LandStepController) {
      var controller = _editPropertyController.currentController
          .value as LandStepController;

      // Create all amenities with initial value false
      _landAmenities = Map.fromIterable(
          _landAmenities.keys, key: (key) => key, value: (key) => false);

      // Set true for amenities in controller's mAmenities
      for (var amenity in controller.mAmenities) {
        if (_landAmenities.containsKey(amenity)) {
          _landAmenities[amenity] = true;
        }
      }
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (options.contains(_editPropertyController.selectedPropertyOption.value)){
  //     _selectedOption.value = _editPropertyController.selectedPropertyOption.value;
  //   } else {
  //     _selectedOption.value = options[0];
  //     _editPropertyController.selectedPropertyOption.value = _selectedOption.value;
  //   }
  // }


  void _onContainerTap(String option) {
    setState(() {
      // _landStepController = Get.find<LandStepController>();
      _selectedOption.value = option;
      _landStepController.option.value = option;
      _editPropertyController.selectedPropertyOption.value = option;
      print("The value is: ${_landStepController.option.value}");
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: options.expand((option) => [
                  SelectableContainer(
                    option: option,
                    icon: Icons.cabin,
                    selectedOption: _selectedOption.value,
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
                      initialCurrency: _landStepController.currency.value,
                      onCurrencySelected: (String currency) {
                        // Handle the selected currency here
                        _landStepController.currency.value = currency;
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
              controller: _editPropertyController.currentController.value is LandStepController
                  ? (_editPropertyController.currentController.value as LandStepController).priceController.value
                  : TextEditingController(),  // Use an empty TextEditingController by default
              onChanged: (text) {
                if (_editPropertyController.currentController.value is LandStepController) {
                  var controller = (_editPropertyController.currentController.value as LandStepController);
                  controller.price.value
                  ;
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
              controller: _editPropertyController.currentController.value is LandStepController
                  ? (_editPropertyController.currentController.value as LandStepController).squareMetersController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController.value is LandStepController) {
                  var controller = (_editPropertyController.currentController.value as LandStepController);
                  controller.squareMeters.value;
                }
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Area',
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
              controller: _editPropertyController.currentController.value is LandStepController
                  ? (_editPropertyController.currentController.value as LandStepController).descriptionController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController.value is LandStepController) {
                  var controller = (_editPropertyController.currentController.value as LandStepController);
                  controller.description.value;
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
                      if (_editPropertyController.currentController.value is LandStepController) {
                        var controller = (_editPropertyController.currentController.value as LandStepController);
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
