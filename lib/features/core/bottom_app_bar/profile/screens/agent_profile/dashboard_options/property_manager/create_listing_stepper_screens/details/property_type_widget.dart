import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/create_listing_stepper_screens/details/residential_widget.dart';
import 'package:property_match_258_v5/widgets/agent_property_listing_widgets/radio_button.dart';
import 'package:sizer/sizer.dart';

import 'commercial_widget.dart';
import 'industrial_widget.dart';
import 'land_widget.dart';

class PropertyType extends StatefulWidget {
  final List<GlobalKey<FormState>> formKey;
  final TabController tabController;

  const PropertyType(
      {super.key, required this.tabController, required this.formKey});

  @override
  State<PropertyType> createState() => _PropertyTypeState();
}

class _PropertyTypeState extends State<PropertyType> {
  final ListingController _listingController = Get.find<ListingController>();

  final List<String> _tabs = [
    "Residential",
    "Commercial",
    "Industrial",
    "Land"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listingController.selectedPropertyType.isEmpty) {
        _listingController.selectedPropertyType.value = _tabs[0];
        _listingController.changeTab(widget.tabController.index);
      }

      widget.tabController.addListener(() {
        print("TabController listener triggered");

        if (!widget.tabController.indexIsChanging) {
          String newSelectedPropertyType = _tabs[widget.tabController.index];
          if (_listingController.selectedPropertyType.value !=
              newSelectedPropertyType) {
            _listingController.selectedPropertyType.value =
                newSelectedPropertyType;
            _listingController.changeTab(widget.tabController.index);
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<ListingController>(
            init: ListingController(),
            builder: (controller) => RadioButtonWidget(
              selectedStatus: controller.forSaleOrRent,
              updateStatus: controller.updateRentOrSale,
            ),
          ),
          SizedBox(
            height: 1.5.h,
          ),
          Container(
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(50.h),
            ),
            child: TabBar(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              tabAlignment: TabAlignment.center,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black87,
              isScrollable: true,
              // Set isScrollable to true
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(25.0),
              ),
              controller: widget.tabController,
              tabs: [
                Tab(
                  child: Text(
                    "Residential",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Commercial",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Industrial",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "Land",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: "Roboto",
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: 51.5.h,
              child: TabBarView(
                controller: widget.tabController,
                children: [
                  ResidentialWidget(
                    formKey: widget.formKey[0],
                  ),
                  CommercialWidget(formKey: widget.formKey[1]),
                  IndustrialWidget(formKey: widget.formKey[2]),
                  LandWidget(formKey: widget.formKey[3]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
