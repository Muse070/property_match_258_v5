import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:property_match_258_v5/model/property_models/industrial_property_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../../model/property_models/property_model.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/currency_selection_widget.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/property_type_option.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/radio_button.dart';
import '../../../../../../../controllers/edit_property_step_controllers/edit_property_controller.dart';
import '../../../../../../../controllers/edit_property_step_controllers/industrial_step_controller.dart';
import '../../../../../../../controllers/property_type_controllers/listing_controller.dart';
import '../../../../../../../controllers/property_type_controllers/industrial_controller.dart';

class IndustrialDetailsStep extends StatefulWidget {
  final PropertyModel property;
  const IndustrialDetailsStep({super.key, required this.property});

  @override
  State<IndustrialDetailsStep> createState() => _IndustrialDetailsStepState();
}

class _IndustrialDetailsStepState extends State<IndustrialDetailsStep> {
  late final EditPropertyController _editPropertyController;

  late final IndustrialStepController _indStepController;


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
    super.initState();

    Get.put<EditPropertyController>(EditPropertyController(widget.property));

    if (widget.property is IndustrialModel) {
      Get.put<IndustrialStepController>(IndustrialStepController(widget.property as IndustrialModel));
    }

    _editPropertyController =
        Get.find<EditPropertyController>(); // Access it later

    _indStepController = Get.find<IndustrialStepController>();
    _selectedOption = _editPropertyController.selectedPropertyOption.value;

    _editPropertyController.updateCurrency(_indStepController.currency.value);


    if (_editPropertyController.currentController.value
    is IndustrialStepController) {
      var controller = _editPropertyController.currentController.value
      as IndustrialStepController;

      // Create all amenities with initial value false
      _industrialAmenities = Map.fromIterable(_industrialAmenities.keys,
          key: (key) => key, value: (key) => false);

      // Set true for amenities in controller's mAmenities
      for (var amenity in controller.mAmenities) {
        if (_industrialAmenities.containsKey(amenity)) {
          _industrialAmenities[amenity] = true;
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
      _indStepController.updatePropertyOption(_selectedOption);
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
                      initialCurrency: _indStepController.currency.value,
                      onCurrencySelected: (String currency) {
                        // Handle the selected currency here
                        _indStepController.currency.value = currency;
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
              controller: _editPropertyController.currentController.value is IndustrialStepController
                  ? (_editPropertyController.currentController.value as IndustrialStepController).priceController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController.value is IndustrialStepController) {
                  var controller = (_editPropertyController.currentController.value as IndustrialStepController);
                  // controller.updatePrice(text);
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
              controller: _editPropertyController.currentController.value is IndustrialStepController
                  ? (_editPropertyController.currentController.value as IndustrialStepController).numFloorsController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController.value is IndustrialStepController) {
                  var controller = (_editPropertyController.currentController.value as IndustrialStepController);
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
              controller: _editPropertyController.currentController.value is IndustrialStepController
                  ? (_editPropertyController.currentController.value as IndustrialStepController).totalAreaController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController.value is IndustrialStepController) {
                  var controller = (_editPropertyController.currentController.value as IndustrialStepController);
                  controller.totalArea.value;
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
              controller: _editPropertyController.currentController.value is IndustrialStepController
                  ? (_editPropertyController.currentController.value as IndustrialStepController).areaPerFloorController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController.value is IndustrialStepController) {
                  var controller = (_editPropertyController.currentController.value as IndustrialStepController);
                  controller.areaPerFloor.value;
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
              controller: _editPropertyController.currentController.value is IndustrialStepController
                  ? (_editPropertyController.currentController.value as IndustrialStepController).descriptionController.value
                  : TextEditingController(),
              onChanged: (text) {
                if (_editPropertyController.currentController.value is IndustrialStepController) {
                  var controller = (_editPropertyController.currentController.value as IndustrialStepController);
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
                      if (_editPropertyController.currentController.value is IndustrialStepController) {
                        // var controller = (_editPropertyController.currentController.value as IndustrialStepController);
                        // controller.;
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
