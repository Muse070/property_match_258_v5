import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/model/property_models/residential_property_model.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../../model/property_models/property_model.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/currency_selection_widget.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/furnished_widget.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/property_type_option.dart';
import '../../../../../../../../../../../widgets/agent_property_listing_widgets/radio_button.dart';
import '../../../../../../../controllers/edit_property_step_controllers/edit_property_controller.dart';
import '../../../../../../../controllers/edit_property_step_controllers/residential_step_controller.dart';

class ResidentialDetailsStep extends StatefulWidget {
  final PropertyModel property;

  const ResidentialDetailsStep({super.key, required this.property});

  @override
  State<ResidentialDetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<ResidentialDetailsStep> {
  final options = [
    'Apartment',
    'Condo',
    'Single-Family',
    'Mansion',
    'Villa',
    'Duplex',
    'Triplex',
    'Quadplex',
  ];

  late Map<String, bool> _amenities = {
    'Kitchen': false,
    'Living Room': false,
    'Dining Room': false,
    "Laundry Room": false,
    'Washing Machine': false,
    'Wi-Fi': false,
    'Garden': false,
    'Laundry Dryer': false,
    'Parking': false,
    'Swimming Pool': false,
    'Gymnasium': false,
    'Security System': false,
    'Power Backup': false,
  };

  String _selectedOption = "";

  late final EditPropertyController _editPropertyController;

  late final ResidentialStepController _resStepController;

  @override
  void initState() {
    super.initState();
    Get.put<EditPropertyController>(EditPropertyController(widget.property));

    if (widget.property is ResidentialModel) {
      Get.put<ResidentialStepController>(ResidentialStepController(widget.property as ResidentialModel));
    }

    _editPropertyController =
        Get.find<EditPropertyController>(); // Access it later

    _resStepController = Get.find<ResidentialStepController>();
    _selectedOption = _editPropertyController.selectedPropertyOption.value;
    // ... other code

    _editPropertyController.updateCurrency(_resStepController.currency.value);
    _editPropertyController.furnished.value = _resStepController.isFurnished.value;

    print("The edit currency we are dealing with is: ${_editPropertyController.currency.value}");
    print("The res currency we are dealing with is: ${_resStepController.currency.value}");

    // Check if current controller is ResidentialStepController
    if (_editPropertyController.currentController.value
        is ResidentialStepController) {
      var controller = _editPropertyController.currentController.value
          as ResidentialStepController;

      // Create all amenities with initial value false
      _amenities = Map.fromIterable(_amenities.keys,
          key: (key) => key, value: (key) => false);

      // Set true for amenities in controller's mAmenities
      for (var amenity in controller.mAmenities) {
        if (_amenities.containsKey(amenity)) {
          _amenities[amenity] = true;
        }
      }
    }
  }

  void _onContainerTap(String option) {
    setState(() {
      _selectedOption = option;
      _resStepController.updatePropertyOption(option);
      _editPropertyController.selectedPropertyOption.value = option;
      print("The value is: ${_editPropertyController.selectedPropertyOption.value}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioButtonWidget(
          selectedStatus: _editPropertyController.forSaleOrRent,
          updateStatus: _editPropertyController.updateRentOrSale,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: options
                .map((option) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: SelectableContainer(
                        option: option,
                        icon: Icons.cabin,
                        selectedOption: _selectedOption,
                        onContainerTap: _onContainerTap,
                      ),
                    ))
                .toList(),
          ),
        ),
        SizedBox(
          height: 1.5.h,
        ),
        Obx(() => Card(
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
                    "Furnishing:",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.0), // Add spacing between rows
                  FurnishedSelectionRow(
                    initialValue: _resStepController.isFurnished.value,
                    onFurnishedSelected: (bool isFurnished) {
                      // _listingController.isFurnished.value = isFurnished;
                      setState(() {
                        // _resStepController.isFurnished.value = isFurnished;
                        print("Furnished or not ${_resStepController.isFurnished.value}");
                        _resStepController.isFurnished.value = isFurnished;
                        _editPropertyController.furnished.value = isFurnished;
                        print("Furnished or not ${_editPropertyController.furnished.value}");
                      });
                    },
                  ),
                  Divider(height: 24.0, thickness: 1.0), // Add a divider
                  Text(
                    "Currency:",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  CurrencySelectionWidget(
                    initialCurrency: _resStepController.currencyController.value.text,
                    onCurrencySelected: (String currency) {

                      // Handle the selected currency here
                      _resStepController.updateCurrency(currency);

                      _editPropertyController.currency.value = currency;

                      print("Currency is lalala: ${_editPropertyController.currency.value}");

                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 1.5.h,
        ),
        TextFormField(
          controller: _editPropertyController.currentController.value
                  is ResidentialStepController
              ? (_editPropertyController.currentController.value
                      as ResidentialStepController)
                  .priceController
                  .value
              : TextEditingController(),
          // Use an empty TextEditingController by default
          onChanged: (text) {
            if (_editPropertyController.currentController.value
                is ResidentialStepController) {
              var controller = (_editPropertyController.currentController.value
                  as ResidentialStepController);
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
          height: 1.5.h,
        ),
        TextFormField(
          controller: _editPropertyController.currentController.value
                  is ResidentialStepController
              ? (_editPropertyController.currentController.value
                      as ResidentialStepController)
                  .numOfBedroomsController
                  .value
              : TextEditingController(),
          onChanged: (text) {
            if (_editPropertyController.currentController.value
                is ResidentialStepController) {
              var controller = (_editPropertyController.currentController.value
                      as ResidentialStepController)
                  .numOfBedroomsController
                  .value;
              controller.text;
            }
          },
          decoration: InputDecoration(
            labelText: 'Number of Bedrooms',
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
          height: 1.5.h,
        ),
        TextFormField(
          controller: _editPropertyController.currentController.value
                  is ResidentialStepController
              ? (_editPropertyController.currentController.value
                      as ResidentialStepController)
                  .numOfBathroomsController
                  .value
              : TextEditingController(),
          onChanged: (text) {
            if (_editPropertyController.currentController.value
                is ResidentialStepController) {
              var controller = (_editPropertyController.currentController.value
                      as ResidentialStepController)
                  .numOfBathroomsController
                  .value;
              controller.text;
            }
          },
          decoration: InputDecoration(
            labelText: 'Number of Bathrooms',
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
          height: 1.5.h,
        ),
        TextFormField(
          controller: _editPropertyController.currentController.value
                  is ResidentialStepController
              ? (_editPropertyController.currentController.value
                      as ResidentialStepController)
                  .descriptionController
                  .value
              : TextEditingController(),
          onChanged: (text) {
            if (_editPropertyController.currentController.value
                is ResidentialStepController) {
              var controller = (_editPropertyController.currentController.value
                      as ResidentialStepController)
                  .descriptionController
                  .value;
              controller.text;
            }
          },
          minLines: 3,
          // Change as needed
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
          height: 1.5.h,
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
          children: _amenities.keys.map((String key) {
            return CheckboxListTile(
              title: Text(key),
              value: _amenities[key],
              onChanged: (value) {
                setState(() {
                  _amenities[key] = value!;
                  // Get the list of selected amenities
                  List<String> selectedAmenities = _amenities.keys
                      .where((k) => _amenities[k] == true)
                      .toList();
                  if (_editPropertyController.currentController.value
                      is ResidentialStepController) {
                    var controller = (_editPropertyController
                        .currentController.value as ResidentialStepController);
                    controller.updateAmenities(selectedAmenities);
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
    );
  }
}
