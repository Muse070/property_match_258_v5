import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/create_listing_stepper_screens/create_new_listing.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/listing_manager/edit_property.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/property_manager/create_listing_stepper_screens/stepper_widget.dart';
import 'package:property_match_258_v5/model/property_models/commercial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/industrial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/land_property_model.dart';
import 'package:property_match_258_v5/model/property_models/residential_property_model.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../model/property_models/property_model.dart';
import '../../../../../../../../repository/properties_repository/property_repository.dart';
import '../../../../../../../../widgets/explore_page_widgets/imageCarousel.dart';

class PropertyManager extends StatefulWidget {
  const PropertyManager({super.key});

  @override
  State<PropertyManager> createState() => _PropertyManagerState();
}

class _PropertyManagerState extends State<PropertyManager>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  final _propertyController = Get.find<PropertyRepository>();
  final _listingController = Get.find<ListingController>();
  final _userRepo = Get.find<UserRepository>();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _tabController = TabController(length: 2, vsync: this);

    final _propertyController = Get.find<PropertyRepository>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: IconTheme(
            data: IconThemeData(
              size: 12.sp,
              color: Colors.white,
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Property Listings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            fontFamily: "Roboto",
          ),
        ),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
        color: Colors.grey.shade200,
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        // padding: EdgeInsets.all(10.sp),
        color: Colors.grey.shade200,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0)),
              child: TabBar(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                tabAlignment: TabAlignment.center,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black87,
                isScrollable: false,
                // Set isScrollable to true
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(25.0),
                ),
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Text(
                      "My Listings",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "Roboto",
                          fontSize: 10.sp),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Create Listing",
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontFamily: "Roboto",
                          fontSize: 10.sp),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 0.7.h,),
            Expanded(
              child: Container(
                color: Colors.grey.shade200, // height: 75.5.h,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Obx(() {
                      return ListView.builder(
                        itemCount: _userRepo.properties.length,
                        itemBuilder: (context, index) => _userRepo.properties.isEmpty
                            ? _shimmerCard() // Display shimmer if empty
                            : propertyCard(_userRepo.properties[index]), // Build property card
                      );
                    }),
                    Center(
                      child: SizedBox(
                        height: 35.h,
                        child: Card(
                          elevation: 5,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10.sp),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    IconTheme(
                                      data: IconThemeData(
                                        size: 16.sp,
                                        color: Colors.black87,
                                      ),
                                      child: const FaIcon(
                                          FontAwesomeIcons.squarePlus),
                                    ), // Add icon here
                                    SizedBox(width: 2.h),
                                    Text(
                                      'Create a New Listing',
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "San Francisco"),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Tap the button below to start creating a new listing.',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                  ),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  icon: IconTheme(
                                    data: IconThemeData(
                                        size: 16.sp, color: Colors.white),
                                    child: const FaIcon(FontAwesomeIcons.plus),
                                  ),
                                  label: Text(
                                    'Create Listing',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp),
                                  ),
                                  onPressed: () {
                                    Get.to(() => const CreateNewListing());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.w, vertical: 1.5.h),
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF005555),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.w),
                                    ),
                                  ),
                                ),
                                const Spacer()
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget propertyCard(PropertyModel property) {
    return Card(
      color: Colors.white,
      elevation: 0.1,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(1.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: ImageCarousel(
                    // Replace with your image carousel implementation
                    imageList: property.images,
                    height: 3.h,
                    width: 90.w,
                    // Adjust height and width as needed
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Property details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 0.5.h,
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 1.2.w, vertical: 0.3.h),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.h)),
                            ),
                            child: Text(
                              property.saleOrRent,
                              // Adjust text based on property status
                              style: TextStyle(
                                color: Color(0xFF80CBC4),
                                fontSize: 8.sp,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 0.5.h,
                          ),
                          Text(
                            "${property.propertyType} (${property.propertyOption})",
                            style: TextStyle(
                                fontSize: 11.sp, color: Colors.grey[800]),
                          ),
                          SizedBox(
                            height: 0.5.h,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${property.address}, ${property.city}",
                                  style: TextStyle(
                                      fontSize: 10.sp, color: Colors.grey[700]),
                                  overflow:
                                      TextOverflow.ellipsis, // Enable ellipsis
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Edit and delete buttons
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Allow agent to edit the property
                        Get.to(() => EditProperty(property: property));
                      },
                      icon: Icon(Icons.edit),
                      label: Text('Edit'),
                      style: TextButton.styleFrom(
                        primary: Colors.black54,
                        // adjust style as needed
                      ),
                    ),
                    SizedBox(width: 5.0),
                    TextButton.icon(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return _buildDeleteConfirmationDialog(
                            context,
                            property
                          );
                        },
                      ),
                      icon: Icon(Icons.delete),
                      label: Text('Delete'),
                      style: TextButton.styleFrom(
                        primary: Colors.black54,
                        // adjust style as needed
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return Card(
      color: Colors.white,
      elevation: 0.1,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmering placeholder for image carousel
                SizedBox(
                  height: 25.h,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.image,
                          size: 100.sp, // Adjust icon size as needed
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Shimmering placeholder for property details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5.0,
                    ),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 15.0, // Adjust height as needed
                        width: double.infinity, // Match full width
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 10.0, // Adjust height as needed
                        width: double.infinity, // Match full width
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 10.0, // Adjust height as needed
                        width: double.infinity, // Match full width
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Shimmering placeholder for bottom row
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 30.0, // Adjust height as needed
                        width: 60.0, // Define explicit width
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 30.0, // Adjust height as needed
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteConfirmationDialog(
    BuildContext context,
      PropertyModel propertyModel
  ) {
    return AlertDialog(
      title: Text('Delete Property Confirmation'),
      content: Text('Are you sure you want to delete this property?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Handle delete action with propertyId
            _propertyController.deleteProperty(propertyModel.id);
            _userRepo.refreshProperties();
            Navigator.pop(context);
            // Implement logic to delete property with propertyId
          },
          child: Text('Proceed'),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
