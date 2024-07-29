import 'dart:async';
import 'dart:io'; // Import for File class

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:readmore/readmore.dart';
import 'package:property_match_258_v5/controllers/favoritesController/favorites_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/agent_details.dart';
import 'package:property_match_258_v5/features/core/pages/chat_page.dart';
import 'package:property_match_258_v5/model/property_models/commercial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/industrial_property_model.dart';
import 'package:property_match_258_v5/model/property_models/land_property_model.dart';
import 'package:property_match_258_v5/model/property_models/property_model.dart';
import 'package:property_match_258_v5/model/property_models/residential_property_model.dart';
import 'package:property_match_258_v5/model/user_models/agent_model.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../../widgets/agent_property_listing_widgets/custom_marker.dart';

class PropertyDetails extends StatefulWidget {
  final AgentModel? agentDetails;
  final PropertyModel propertyDetails;

  const PropertyDetails({
    super.key,
    required this.agentDetails,
    required this.propertyDetails,
  });

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class _PropertyDetailsState extends State<PropertyDetails>
    with TickerProviderStateMixin {
  final GlobalKey _markerKey = GlobalKey();

  final _userRepo = Get.find<UserRepository>();
  late FavoriteController _favoriteController;

  GoogleMapController? mapController;

  bool isMarkerOffScreen = false;

  BitmapDescriptor? customIcon;

  List<Marker> markers = [];

  late TabController _tabController;

  bool isFavorite = false;

  int pages = 0;
  bool isReady = false;
  final pdfController = Completer<PDFViewController>();

  double _downloadProgress = 0.0; // Initialize downloadProgress

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _favoriteController = Get.find<FavoriteController>();
    print(
        "Favorite boolean for property is: ${_favoriteController.isFavorite(widget.propertyDetails.id)}");
  }

  void _openPDF(BuildContext context, String firestoreUrl) async {
    final ref = firebase_storage.FirebaseStorage.instance.refFromURL(firestoreUrl);

    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${ref.name}');

      // Check if the file exists
      if (!await file.exists()) {
        // Show a dialog with a progress indicator while downloading
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissing the dialog
          builder: (context) => AlertDialog(
            title: const Text("Downloading PDF..."),
            content: ValueListenableBuilder<double>(
              valueListenable: ValueNotifier(_downloadProgress),
              builder: (context, progress, child) {
                return LinearProgressIndicator(value: progress);
              },
            ),
          ),
        );

        try {
          await ref.writeToFile(file).snapshotEvents.listen((taskSnapshot) {
            setState(() {
              _downloadProgress =
                  taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
            });
          });
        } catch (e) {
          // ... (error handling for download failure)
        }

        // Dismiss the dialog after download completes
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (await file.exists()) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFView(
              filePath: file.path,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }
  String formatPrice(String price) {
    double value = double.parse(price);
    NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');

    return 'ZMW ${formatter.format(value)}'; // Display the full price with commas
  }

  @override
  Widget build(BuildContext context) {
    _tabController = TabController(length: 3, vsync: this);

    if (widget.propertyDetails is ResidentialModel) {
      var residentialProperty = widget.propertyDetails as ResidentialModel;
      late final documents = residentialProperty.documents;
      print("The documents are: $documents");
      return Scaffold(
        appBar: appBarWidget(residentialProperty.id),
        body: Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
          color: Colors.grey.shade300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: TabBarWidget(tabController: _tabController),
              ),
              SizedBox(height: 1.5.h),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "${residentialProperty.propertyType} ${residentialProperty.propertyOption}",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: Text(
                                "For Sale",
                                style: TextStyle(
                                    fontSize: 9.sp, color: Colors.black54),
                              ),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(FontAwesomeIcons.circleDot),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Price",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: Text(
                                formatPrice(residentialProperty.price),
                                style: TextStyle(
                                    fontSize: 9.sp, color: Colors.black54),
                              ),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(
                                    FontAwesomeIcons.moneyBill1Wave),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        // Location & map widget
                        SizedBox(
                          height: 44.h,
                          width: 100.w,
                          child: Card(
                            color: Colors.white,
                            elevation: 0.2,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    "Location",
                                    style: TextStyle(
                                        fontSize: 10.sp, color: Colors.black87, overflow: TextOverflow.ellipsis),
                                  ),
                                  subtitle: Text(
                                    "${residentialProperty.address}, ${residentialProperty.city}",
                                    style: TextStyle(
                                        fontSize: 9.sp, color: Colors.black54),
                                  ),
                                  leading: IconTheme(
                                    data: IconThemeData(
                                      size: 11.sp,
                                      color: Colors.black87,
                                    ),
                                    child: const FaIcon(
                                        FontAwesomeIcons.locationDot),
                                  ),
                                ),
                                SizedBox(
                                  height: 25.h,
                                  width: 90.w,
                                  child: _googleMap(),
                                ),
                                SizedBox(height: 1.2.h),
                                ElevatedButton(
                                  onPressed: () {},  // Your existing onPressed logic
                                  style: ElevatedButton.styleFrom(  // Use ElevatedButton.styleFrom for convenient styling
                                    backgroundColor: Colors.black87,  // Main button color (could be a gradient or image too)
                                    foregroundColor: const Color(0xFF80CBC4), // Text color
                                    textStyle: TextStyle(
                                      fontSize: 12.sp,  // Slightly larger font size
                                      fontWeight: FontWeight.w800,
                                    ),
                                    elevation: 5.0,  // Adds a subtle shadow
                                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Adjust padding to taste
                                    shape: RoundedRectangleBorder(  // Customizes button shape
                                      borderRadius: BorderRadius.circular(25.0), // More rounded corners
                                      side: BorderSide(color: Color(0xFF80CBC4)), // Adds a subtle border
                                    ),
                                  ),
                                  child: Text("View Map", style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600
                                  ),),  // No need for Container here
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        // Property Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Card(
                              color: Colors.white,
                              elevation: 0.2,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.7.w, vertical: 1.3.h),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.bed,
                                        size: 11.sp, color: Colors.black87),
                                    SizedBox(
                                      width: 1.5.w,
                                    ),
                                    Text(
                                      "${residentialProperty.numOfBedrooms} bds",
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 60,
                              child: VerticalDivider(
                                thickness: 1,
                                indent: 1,
                                endIndent: 1,
                                color: Colors.black45,
                              ),
                            ),
                            Card(
                              color: Colors.white,
                              elevation: 0.2,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.7.w, vertical: 1.3.h),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.bath,
                                        size: 11.sp, color: Colors.black87),
                                    SizedBox(
                                      width: 1.5.w,
                                    ),
                                    Text(
                                      "${residentialProperty.numOfBathrooms} bths",
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 60,
                              child: VerticalDivider(
                                thickness: 1,
                                indent: 1,
                                endIndent: 1,
                                color: Colors.black45,
                              ),
                            ),
                            Card(
                              color: Colors.white,
                              elevation: 0.2,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.7.w, vertical: 1.3.h),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.ruler,
                                        size: 11.sp, color: Colors.black87),
                                    SizedBox(
                                      width: 1.5.w,
                                    ),
                                    Text(
                                      formatSquareMeters(
                                          residentialProperty.squareMeters),
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        // Property Description
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Property Description",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: ReadMoreText(
                                  residentialProperty.description,
                                  style: TextStyle(
                                      fontSize: 9.sp, color: Colors.black54)),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(FontAwesomeIcons.pen),
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        // Agent Details
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Posted By",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: ReadMoreText(
                                  "${widget.agentDetails!.firstName} ${widget.agentDetails!.lastName}",
                                  style: TextStyle(
                                      fontSize: 9.sp, color: Colors.black54)),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(
                                    FontAwesomeIcons.personCircleCheck),
                              ),
                              trailing: widget.agentDetails!.imageUrl != null &&
                                      widget.agentDetails!.imageUrl!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 7.w,
                                      backgroundImage: NetworkImage(
                                          widget.agentDetails!.imageUrl!),
                                    )
                                  : ProfilePicture(
                                      name:
                                          "${widget.agentDetails!.firstName} ${widget.agentDetails!.lastName}",
                                      radius: 7.w,
                                      fontsize: 10.sp,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 7.5.h,
                          child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => AgentDetails(
                                    agentDetails: widget.agentDetails));
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.h),
                                    // Change this value to adjust the border radius
                                    side: const BorderSide(
                                      color: Color(
                                        0xFF005555,
                                      ),
                                    ), // Change this value to your desired border color
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconTheme(
                                    data: IconThemeData(
                                        color: Color(0xFF005555), size: 12.sp),
                                    child: const FaIcon(
                                        FontAwesomeIcons.userCheck),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  Text(
                                    "Agent Profile",
                                    style: TextStyle(
                                      color: Color(0xFF005555),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 7.5.h,
                          child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => ChatPage(
                                      receiverUserId: widget.agentDetails!.id,
                                      currentUserType:
                                          _userRepo.currentUser.value!.userType,
                                      receiverUserType: 'agent',
                                      otherImageUrl:
                                          widget.agentDetails?.imageUrl,
                                      otherFirstName:
                                          widget.agentDetails!.firstName,
                                      otherLastName:
                                          widget.agentDetails!.lastName,
                                    ));
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.h),
                                    // Change this value to adjust the border radius
                                    side: const BorderSide(
                                      color: Color(
                                        0xFF005555,
                                      ),
                                    ), // Change this value to your desired border color
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconTheme(
                                    data: IconThemeData(
                                        color: Color(0xFF005555), size: 12.sp),
                                    child:
                                        const FaIcon(FontAwesomeIcons.message),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  const Text(
                                    "Message Agent",
                                    style: TextStyle(
                                      color: Color(0xFF005555),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        for (var pic in residentialProperty.images) ...[
                          SizedBox(
                            height: 30.h,
                            width: 100.w,
                            child: FadeInImage(
                              placeholder:
                                  AssetImage('assets/images/loading.png'),
                              // Path to your placeholder image
                              image: NetworkImage(pic),
                              fit: BoxFit.fitWidth,
                              placeholderErrorBuilder:
                                  (context, error, stackTrace) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Icon(
                                    Icons.image,
                                    // Choose an appropriate icon
                                    size: 30.h,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Icon(
                                    Icons.error,
                                    // Choose an appropriate icon
                                    size: 30.h,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          Divider(),
                          SizedBox(height: 1.5.h),
                        ]
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: documents.isEmpty
                        ? Center(
                            // Centers the entire content of the screen
                            heightFactor: 0.5.h,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              // Centers column children vertically
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No documents yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                      height: 94.h,
                      child: ListView.builder(
                        itemCount: documents.length,
                        itemBuilder: (context, index) {
                          final filePath = documents[index];
                          return Card( // Add Card for rounded corners and elevation
                            elevation: 0.2,
                            color: Colors.white,
                            shape: RoundedRectangleBorder( // Customize the shape
                              borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                // tileColor: Colors.white, // Set background color for the ListTile
                                leading: const Icon(Icons.picture_as_pdf), // Add PDF icon
                                title: Text("Untitled Pdf"),
                                onTap: () {
                                  print("The document you opened has file path: ${documents[index]}");
                                  _openPDF(context, filePath);
                                  },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      );
    } else if (widget.propertyDetails is CommercialModel) {
      var commercialProperty = widget.propertyDetails as CommercialModel;
      return Scaffold(
        appBar: appBarWidget(commercialProperty.id),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
          height: 100.h,
          width: 100.w,
          color: Colors.grey.shade300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: TabBarWidget(tabController: _tabController)),
              SizedBox(height: 1.5.h),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "${commercialProperty.propertyType} ${commercialProperty.propertyOption}",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black54),
                              ),
                              subtitle: Text(
                                "For Sale",
                                style: TextStyle(
                                    fontSize: 9.sp, color: Colors.black54),
                              ),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(FontAwesomeIcons.circleDot),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Price",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: Text(
                                formatPrice(commercialProperty.price),
                                style: TextStyle(
                                    fontSize: 9.sp, color: Colors.black54),
                              ),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(
                                    FontAwesomeIcons.moneyBill1Wave),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        // Location & map widget
                        SizedBox(
                          height: 38.h,
                          width: 100.w,
                          child: Card(
                            color: Colors.white,
                            elevation: 0.2,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    "Location",
                                    style: TextStyle(
                                        fontSize: 10.sp, color: Colors.black87),
                                  ),
                                  subtitle: Text(
                                    "${commercialProperty.address}, ${commercialProperty.city}",
                                    style: TextStyle(
                                        fontSize: 9.sp, color: Colors.black54),
                                  ),
                                  leading: IconTheme(
                                    data: IconThemeData(
                                      size: 11.sp,
                                      color: Colors.black87,
                                    ),
                                    child: const FaIcon(
                                        FontAwesomeIcons.locationDot),
                                  ),
                                ),
                                SizedBox(
                                  height: 25.h,
                                  width: 90.w,
                                  child: _googleMap(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        // Property Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Card(
                              color: Colors.white,
                              elevation: 0.2,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w, vertical: 1.7.h),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.stairs,
                                        size: 12.sp, color: Colors.black87),
                                    SizedBox(
                                      width: 1.5.w,
                                    ),
                                    Text(
                                      "${commercialProperty.numOfFloors} floors",
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 60,
                              child: VerticalDivider(
                                thickness: 1,
                                indent: 1,
                                endIndent: 1,
                                color: Colors.black45,
                              ),
                            ),
                            Card(
                              color: Colors.black87,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w, vertical: 1.7.h),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.ruler,
                                        size: 12.sp, color: Colors.black87),
                                    SizedBox(
                                      width: 1.5.w,
                                    ),
                                    Text(
                                      formatSquareMeters(
                                          commercialProperty.squareMeters),
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        // Property Description
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Property Description",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: ReadMoreText(
                                  commercialProperty.description,
                                  style: TextStyle(
                                      fontSize: 9.sp, color: Colors.black54)),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(FontAwesomeIcons.pen),
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        // Agent Details
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Posted By",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: ReadMoreText(
                                  "${widget.agentDetails!.firstName} ${widget.agentDetails!.lastName}",
                                  style: TextStyle(
                                      fontSize: 9.sp, color: Colors.black54)),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(
                                    FontAwesomeIcons.personCircleCheck),
                              ),
                              trailing: widget.agentDetails!.imageUrl != null &&
                                      widget.agentDetails!.imageUrl!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 7.w,
                                      backgroundImage: NetworkImage(
                                          widget.agentDetails!.imageUrl!),
                                    )
                                  : ProfilePicture(
                                      name:
                                          "${widget.agentDetails!.firstName} ${widget.agentDetails!.lastName}",
                                      radius: 7.w,
                                      fontsize: 10.sp,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 7.5.h,
                          child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => AgentDetails(
                                    agentDetails: widget.agentDetails));
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.h),
                                    // Change this value to adjust the border radius
                                    side: const BorderSide(
                                      color: Color(
                                        0xFF005555,
                                      ),
                                    ), // Change this value to your desired border color
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconTheme(
                                    data: IconThemeData(
                                        color: Color(0xFF005555), size: 12.sp),
                                    child: const FaIcon(
                                        FontAwesomeIcons.userCheck),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  const Text(
                                    "Agent Profile",
                                    style: TextStyle(
                                      color: Color(0xFF005555),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 7.5.h,
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.h),
                                    // Change this value to adjust the border radius
                                    side: const BorderSide(
                                      color: Color(
                                        0xFF005555,
                                      ),
                                    ), // Change this value to your desired border color
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconTheme(
                                    data: IconThemeData(
                                        color: Color(0xFF005555), size: 12.sp),
                                    child:
                                        const FaIcon(FontAwesomeIcons.message),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  const Text(
                                    "Message Agent",
                                    style: TextStyle(
                                      color: Color(0xFF005555),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        for (var pic in commercialProperty.images) ...[
                          SizedBox(
                            height: 30.h,
                            width: 100.w,
                            child: Image.network(
                              pic,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          const Divider(),
                          SizedBox(height: 1.5.h),
                        ]
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      );
    } else if (widget.propertyDetails is IndustrialModel) {
      var industrialProperty = widget.propertyDetails as IndustrialModel;
      return Scaffold(
        appBar: appBarWidget(industrialProperty.id),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
          height: 100.h,
          width: 100.w,
          color: Colors.grey.shade300,
          child: Column(
            children: [
              Center(child: TabBarWidget(tabController: _tabController)),
              SizedBox(height: 1.5.h),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "${industrialProperty.propertyType} ${industrialProperty.propertyOption}",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: Text(
                                "For Sale",
                                style: TextStyle(
                                    fontSize: 9.sp, color: Colors.black54),
                              ),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(FontAwesomeIcons.circleDot),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Price",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: Text(
                                formatPrice(industrialProperty.price),
                                style: TextStyle(
                                    fontSize: 9.sp, color: Colors.black54),
                              ),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(
                                    FontAwesomeIcons.moneyBill1Wave),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        // Location & map widget
                        SizedBox(
                          height: 38.h,
                          width: 100.w,
                          child: Card(
                            color: Colors.white,
                            elevation: 0.2,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    "Location",
                                    style: TextStyle(
                                        fontSize: 10.sp, color: Colors.black87),
                                  ),
                                  subtitle: Text(
                                    "${industrialProperty.address}, ${industrialProperty.city}",
                                    style: TextStyle(
                                        fontSize: 9.sp, color: Colors.black54),
                                  ),
                                  leading: IconTheme(
                                    data: IconThemeData(
                                      size: 11.sp,
                                      color: Colors.black87,
                                    ),
                                    child: const FaIcon(
                                        FontAwesomeIcons.locationDot),
                                  ),
                                ),
                                SizedBox(
                                  height: 25.h,
                                  width: 90.w,
                                  child: _googleMap(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        // Property Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Card(
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w, vertical: 1.7.h),
                                child: Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.stairs,
                                      size: 12.sp,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(
                                      width: 1.5.w,
                                    ),
                                    Text(
                                      "${industrialProperty.numOfFloors} floors",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 60,
                              child: VerticalDivider(
                                thickness: 1,
                                indent: 1,
                                endIndent: 1,
                                color: Colors.black45,
                              ),
                            ),
                            Card(
                              elevation: 0.2,
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w, vertical: 1.7.h),
                                child: Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.rulerCombined,
                                      size: 12.sp,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(
                                      width: 1.5.w,
                                    ),
                                    Text(
                                      "${formatSquareMeters(industrialProperty.areaPerFloor)}/ floor",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 60,
                              child: VerticalDivider(
                                thickness: 1,
                                indent: 1,
                                endIndent: 1,
                                color: Colors.black45,
                              ),
                            ),
                            Card(
                              color: Colors.white,
                              elevation: 0.2,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w, vertical: 1.7.h),
                                child: Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.ruler,
                                      size: 12.sp,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(
                                      width: 1.5.w,
                                    ),
                                    Text(
                                      formatSquareMeters(
                                          industrialProperty.totalArea),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        // Property Description
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Property Description",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: ReadMoreText(
                                  industrialProperty.description,
                                  style: TextStyle(
                                      fontSize: 9.sp, color: Colors.black54)),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(FontAwesomeIcons.pen),
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        // Agent Details
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Posted By",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: ReadMoreText(
                                  "${widget.agentDetails!.firstName} ${widget.agentDetails!.lastName}",
                                  style: TextStyle(
                                      fontSize: 9.sp, color: Colors.black54)),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(
                                    FontAwesomeIcons.personCircleCheck),
                              ),
                              trailing: widget.agentDetails!.imageUrl != null &&
                                      widget.agentDetails!.imageUrl!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 7.w,
                                      backgroundImage: NetworkImage(
                                          widget.agentDetails!.imageUrl!),
                                    )
                                  : ProfilePicture(
                                      name:
                                          "${widget.agentDetails!.firstName} ${widget.agentDetails!.lastName}",
                                      radius: 7.w,
                                      fontsize: 10.sp,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 7.5.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => AgentDetails(
                                  agentDetails: widget.agentDetails));
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2.h),
                                  // Change this value to adjust the border radius
                                  side: const BorderSide(
                                    color: Color(
                                      0xFF005555,
                                    ),
                                  ), // Change this value to your desired border color
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconTheme(
                                  data: IconThemeData(
                                      color: Color(0xFF005555), size: 12.sp),
                                  child:
                                      const FaIcon(FontAwesomeIcons.userCheck),
                                ),
                                SizedBox(
                                  width: 2.w,
                                ),
                                const Text(
                                  "Agent Profile",
                                  style: TextStyle(
                                    color: Color(0xFF005555),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 7.5.h,
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.h),
                                    // Change this value to adjust the border radius
                                    side: const BorderSide(
                                      color: Color(
                                        0xFF005555,
                                      ),
                                    ), // Change this value to your desired border color
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Message Agent",
                                    style: TextStyle(
                                      color: Color(0xFF005555),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  IconTheme(
                                    data: IconThemeData(
                                        color: const Color(0xFF005555),
                                        size: 12.sp),
                                    child:
                                        const FaIcon(FontAwesomeIcons.message),
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        for (var pic in industrialProperty.images) ...[
                          SizedBox(
                            height: 30.h,
                            width: 100.w,
                            child: Image.network(
                              pic,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          const Divider(),
                          SizedBox(height: 1.5.h),
                        ]
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      );
    } else if (widget.propertyDetails is LandModel) {
      var landProperty = widget.propertyDetails as LandModel;
      return Scaffold(
        appBar: appBarWidget(landProperty.id),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
          height: 100.h,
          width: 100.w,
          color: Colors.grey.shade300,
          child: Column(
            children: [
              Center(child: TabBarWidget(tabController: _tabController)),
              SizedBox(height: 1.5.h),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "${landProperty.propertyType} ${landProperty.propertyOption}",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: Text(
                                "For Sale",
                                style: TextStyle(
                                    fontSize: 9.sp, color: Colors.black54),
                              ),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(FontAwesomeIcons.circleDot),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Price",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: Text(
                                formatPrice(landProperty.price),
                                style: TextStyle(
                                    fontSize: 9.sp, color: Colors.black54),
                              ),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(
                                    FontAwesomeIcons.moneyBill1Wave),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        // Location & map widget
                        SizedBox(
                          height: 38.h,
                          width: 100.w,
                          child: Card(
                            color: Colors.white,
                            elevation: 0.2,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(
                                    "Location",
                                    style: TextStyle(
                                        fontSize: 10.sp, color: Colors.black87),
                                  ),
                                  subtitle: Text(
                                    "${landProperty.address}, ${landProperty.city}",
                                    style: TextStyle(
                                        fontSize: 9.sp, color: Colors.black54),
                                  ),
                                  leading: IconTheme(
                                    data: IconThemeData(
                                      size: 11.sp,
                                      color: Colors.black87,
                                    ),
                                    child: const FaIcon(
                                        FontAwesomeIcons.locationDot),
                                  ),
                                ),
                                SizedBox(
                                  height: 25.h,
                                  width: 90.w,
                                  child: _googleMap(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        // Property Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Card(
                              color: Colors.white,
                              elevation: 0.2,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w, vertical: 1.7.h),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.ruler,
                                        size: 12.sp, color: Colors.black87),
                                    SizedBox(
                                      width: 1.5.w,
                                    ),
                                    Text(
                                      formatSquareMeters(
                                          landProperty.squareMeters),
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.5.h),
                        // Property Description
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Property Description",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: ReadMoreText(landProperty.description,
                                  style: TextStyle(
                                      fontSize: 9.sp, color: Colors.black54)),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(FontAwesomeIcons.pen),
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        // Agent Details
                        Card(
                          color: Colors.white,
                          elevation: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                "Posted By",
                                style: TextStyle(
                                    fontSize: 10.sp, color: Colors.black87),
                              ),
                              subtitle: ReadMoreText(
                                  "${widget.agentDetails!.firstName} ${widget.agentDetails!.lastName}",
                                  style: TextStyle(
                                      fontSize: 9.sp, color: Colors.black54)),
                              leading: IconTheme(
                                data: IconThemeData(
                                  size: 11.sp,
                                  color: Colors.black87,
                                ),
                                child: const FaIcon(
                                    FontAwesomeIcons.personCircleCheck),
                              ),
                              trailing: widget.agentDetails!.imageUrl != null &&
                                      widget.agentDetails!.imageUrl!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 7.w,
                                      backgroundImage: NetworkImage(
                                          widget.agentDetails!.imageUrl!),
                                    )
                                  : ProfilePicture(
                                      name:
                                          "${widget.agentDetails!.firstName} ${widget.agentDetails!.lastName}",
                                      radius: 7.w,
                                      fontsize: 10.sp,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 7.5.h,
                          child: ElevatedButton(
                              onPressed: () {
                                Get.to(() => AgentDetails(
                                    agentDetails: widget.agentDetails));
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.h),
                                    // Change this value to adjust the border radius
                                    side: const BorderSide(
                                      color: Color(
                                        0xFF005555,
                                      ),
                                    ), // Change this value to your desired border color
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconTheme(
                                    data: IconThemeData(
                                        color: Color(
                                          0xFF005555,
                                        ),
                                        size: 12.sp),
                                    child: const FaIcon(
                                        FontAwesomeIcons.userCheck),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  const Text(
                                    "Agent Profile",
                                    style: TextStyle(
                                      color: Color(
                                        0xFF005555,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(height: 1.5.h),
                        SizedBox(
                          height: 7.5.h,
                          child: ElevatedButton(
                              onPressed: () {},
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2.h),
                                    // Change this value to adjust the border radius
                                    side: const BorderSide(
                                      color: Color(
                                        0xFF005555,
                                      ),
                                    ), // Change this value to your desired border color
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Message Agent",
                                    style: TextStyle(
                                      color: Color(0xFF005555),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 2.w,
                                  ),
                                  IconTheme(
                                    data: IconThemeData(
                                        color: const Color(0xFF005555),
                                        size: 12.sp),
                                    child:
                                        const FaIcon(FontAwesomeIcons.message),
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(height: 1.5.h),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        for (var pic in landProperty.images) ...[
                          SizedBox(
                            height: 30.h,
                            width: 100.w,
                            child: Image.network(
                              pic,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                          const Divider(),
                          SizedBox(height: 1.5.h),
                        ]
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  //-------------------------------------------------------------------------//
  //------------------------Helper methods-----------------------------------//

  String formatSquareMeters(String squareMeters) {
    return '${double.parse(squareMeters)} m²';
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setMarker();
    print("Marker list is: $markers");
  }

  void setMarker() {
    print("setMarker called");

    try {
      Marker myMarker = Marker(
        markerId: MarkerId(widget.propertyDetails.address),
        alpha: 0.9,
        position: LatLng(
            widget.propertyDetails.latitude, widget.propertyDetails.longitude),
        infoWindow: InfoWindow(
          title: widget.propertyDetails.address,
        ),
      );

      setState(() {
        markers.clear();
        markers.add(myMarker);
      });

      print("Markers list is: $markers");
    } catch (e) {
      print("Exception in setMarker: $e");
    }
  }

  Widget _googleMap() {
    return Stack(children: [
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            widget.propertyDetails.latitude,
            widget.propertyDetails.longitude,
          ),
          zoom: 18,
        ),
        // myLocationEnabled: true,
        mapType: MapType.hybrid,
        markers: Set<Marker>.of(markers),
        zoomControlsEnabled: false,
        onMapCreated: _onMapCreated,
      ),
      Transform.translate(
        offset: Offset(
          -MediaQuery.of(context).size.width * 2,
          -MediaQuery.of(context).size.height * 2,
        ),
        child: RepaintBoundary(
          key: _markerKey,
          child: CustomMarker(
            price: widget.propertyDetails.price.obs,
          ),
        ),
      ),
    ]);
  }

  PreferredSizeWidget appBarWidget(String productId) {
    return AppBar(
      backgroundColor: Colors.black87,
      title: Text(
        "Property Details",
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: "Roboto",
            fontSize: 14.sp),
      ),
      // titleTextStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
      leading: IconButton(
        icon: IconTheme(
          data: IconThemeData(
            size: 14.sp,
            color: Colors.white,
          ),
          child: const FaIcon(FontAwesomeIcons.angleLeft),
        ),
        onPressed: () {
          Get.back();
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _favoriteController.toggleFavoriteProduct(productId);
            });
          },
          icon: IconTheme(
            data: IconThemeData(
              color: _favoriteController.isFavorite(productId)
                  ? Colors.red
                  : Colors.white,
              size: 14.sp,
            ),
            child: FaIcon(_favoriteController.isFavorite(productId)
                ? FontAwesomeIcons.solidHeart
                : FontAwesomeIcons.heart),
          ),
        ),
      ],
    );
  }
}

class TabBarWidget extends StatelessWidget {
  const TabBarWidget({
    super.key,
    required TabController tabController,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return TabBar(
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
      tabs: const [
        Tab(
          child: Text(
            "Details",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: "Roboto",
            ),
          ),
        ),
        Tab(
          child: Text(
            "Images",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: "Roboto",
            ),
          ),
        ),
        Tab(
          child: Text(
            "Documents",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: "Roboto",
            ),
          ),
        )
      ],
    );
  }
}
