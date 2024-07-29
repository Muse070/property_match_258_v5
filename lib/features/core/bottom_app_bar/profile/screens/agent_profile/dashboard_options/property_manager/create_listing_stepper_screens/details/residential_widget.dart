import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/instance_manager.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/residential_controllers.dart';
import 'package:property_match_258_v5/widgets/agent_property_listing_widgets/currency_selection_widget.dart';
import 'package:property_match_258_v5/widgets/agent_property_listing_widgets/property_type_option.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../../../widgets/agent_property_listing_widgets/furnished_widget.dart';

class ResidentialWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const ResidentialWidget({
    super.key,
    required this.formKey,
  });

  @override
  State<ResidentialWidget> createState() => _ResidentialWidgetState();
}

class _ResidentialWidgetState extends State<ResidentialWidget> {
  final ResidentialController _residentialController =
      Get.find<ResidentialController>();

  final ListingController _listingController = Get.find<ListingController>();

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

  String _selectedOption = "";

  // late ResidentialController _resController;

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

  void _onContainerTap(String option) {
    setState(() {
      _selectedOption = option;
      _listingController.updateSelectedPropertyOption(_selectedOption);
    });
  }

  @override
  void initState() {
    super.initState();
    if (_listingController.currentController.value is ResidentialController) {
      var controller =
          (_listingController.currentController.value as ResidentialController);
      // _resController = (_listingController.currentController.value as ResidentialController);
      _amenities = {
        'Kitchen': controller.mAmenities.contains('Kitchen'),
        'Living Room': controller.mAmenities.contains('Living Room'),
        'Dining Room': controller.mAmenities.contains('Dining Room'),
        "Laundry Room": controller.mAmenities.contains('Laundry Room'),
        'Washing Machine': controller.mAmenities.contains('Washing Machine'),
        'Wi-Fi': controller.mAmenities.contains('Wi-Fi'),
        'Garden': controller.mAmenities.contains('Garden'),
        'Laundry Dryer': controller.mAmenities.contains('Laundry Dryer'),
        'Parking': controller.mAmenities.contains('Parking'),
        'Swimming Pool': controller.mAmenities.contains('Swimming Pool'),
        'Gymnasium': controller.mAmenities.contains('Gymnasium'),
        'Security System': controller.mAmenities.contains('Security System'),
        'Power Backup': controller.mAmenities.contains('Power Backup'),
      };
    }

    _selectedOption = options[0];
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _residentialController.option.value = _selectedOption;
      _listingController.updateSelectedPropertyOption(_selectedOption);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (options.contains(_listingController.selectedPropertyOption.value)) {
      _selectedOption = _listingController.selectedPropertyOption.value;
    } else {
      _selectedOption = options[0];
      _listingController.selectedPropertyOption.value = _selectedOption;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: options
                    .expand((option) => [
                  SelectableContainer(
                    option: option,
                    icon: Icons.cabin,
                    selectedOption: _selectedOption,
                    onContainerTap: _onContainerTap,
                  ),
                  SizedBox(
                    width: 2.w,
                  ),
                ])
                    .toList()
                  ..removeLast(), // Remove the last SizedBox
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
                      "Furnishing:",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.0), // Add spacing between rows
                    FurnishedSelectionRow(
                      initialValue: _residentialController.isFurnished.value,
                      onFurnishedSelected: (bool isFurnished) {
                        // _listingController.isFurnished.value = isFurnished;
                        setState(() {
                          _residentialController.isFurnished.value = isFurnished;
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
            SizedBox(
              height: 1.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Details",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 1.h,
            ),
            TextFormField(
              controller: _listingController.currentController.value
                      is ResidentialController
                  ? (_listingController.currentController.value
                          as ResidentialController)
                      .priceController
                      .value
                  : TextEditingController(),
              // Use an empty TextEditingController by default
              onChanged: (text) {
                if (_listingController.currentController.value
                    is ResidentialController) {
                  var controller = (_listingController.currentController.value
                      as ResidentialController);
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
              controller: _listingController.currentController.value
                      is ResidentialController
                  ? (_listingController.currentController.value
                          as ResidentialController)
                      .numOfBedroomsController
                      .value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value
                    is ResidentialController) {
                  var controller = (_listingController.currentController.value
                      as ResidentialController);
                  controller.updateNumOfBedrooms(text);
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
              height: 2.h,
            ),
            TextFormField(
              controller: _listingController.currentController.value
                      is ResidentialController
                  ? (_listingController.currentController.value
                          as ResidentialController)
                      .numOfBathroomsController
                      .value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value
                    is ResidentialController) {
                  var controller = (_listingController.currentController.value
                      as ResidentialController);
                  controller.updateNumOfBathrooms(text);
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
              height: 2.h,
            ),
            TextFormField(
              controller: _listingController.currentController.value
                      is ResidentialController
                  ? (_listingController.currentController.value
                          as ResidentialController)
                      .squareMetersController
                      .value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value
                    is ResidentialController) {
                  var controller = (_listingController.currentController.value
                      as ResidentialController);
                  controller.updateSquareMeters(text);
                }
              },
              decoration: InputDecoration(
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
              controller: _listingController.currentController.value
                      is ResidentialController
                  ? (_listingController.currentController.value
                          as ResidentialController)
                      .descriptionController
                      .value
                  : TextEditingController(),
              onChanged: (text) {
                if (_listingController.currentController.value
                    is ResidentialController) {
                  var controller = (_listingController.currentController.value
                      as ResidentialController);
                  controller.updateDescription(text);
                }
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(150),
              ],
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
                      if (_listingController.currentController.value
                          is ResidentialController) {
                        var controller = (_listingController
                            .currentController.value as ResidentialController);
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
