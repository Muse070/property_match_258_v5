import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/explore/screens/property_details.dart';
import 'package:sizer/sizer.dart';

import '../../../../../model/property_models/property_model.dart';
import '../../../../../model/user_models/agent_model.dart';
import '../../../../../repository/properties_repository/property_repository.dart';

class PropertySearchScreen extends StatefulWidget {
  const PropertySearchScreen({super.key});

  @override
  State<PropertySearchScreen> createState() => _PropertySearchScreenState();
}

class _PropertySearchScreenState extends State<PropertySearchScreen> {
  final _queryController = TextEditingController();
  final _propertyRepo = Get.find<PropertyRepository>();

  String get searchQuery => _queryController.text;
  final applicationId = "6XOQET1RIW";
  final apiKey = "8d9b87769133243b30267dfbf874e9c6";

  final List<AlgoliaObjectSnapshot> _results = [];
  List<AlgoliaObjectSnapshot> _displayedResults = []; // Separate list for display


  late Algolia _algolia;
  bool _isInitialLoad = true;
  bool _isDataLoading = false; // Flag to track data fetching state
  bool _isFetchingImages = false; // Flag to track image fetching state


  @override
  void initState() {
    super.initState();
    _algolia = Algolia.init(applicationId: applicationId, apiKey: apiKey);
  }

  Future<PropertyModel> fetchProperty(propertyId) async {
    return await _propertyRepo.getProperty(propertyId);
  }

  Future<AgentModel>  fetchAgentDetails(agentId) async {
    return await _propertyRepo.getAgentDetails(agentId);
  }

  Future<void> _fetchProperties() async {
    if (_isInitialLoad) {
      _isInitialLoad = false;
    } else {
      _results.clear();  // Clear for subsequent searches
    }

    setState(() {
      _isDataLoading = true;
      _isFetchingImages = true;
    });

    final query = _algolia.instance.index('properties_index').query(searchQuery);
    final snap = await query.getObjects();
    final results = snap.hits as List<AlgoliaObjectSnapshot>;

    for (var item in results) {
      String propertyId = item
          .data['objectID']; // Assuming an 'id' field exists
      try {
        PropertyModel property = await _propertyRepo.getProperty(propertyId);

        item.data['imageUrl'] = property.images[0]; // (Optional: Keep separate if needed)
        item.data['price'] = property.price;
        item.data['city'] = property.city;
        item.data['agentId'] = property.agentId;
        item.data['propertyId'] = property.id;
        item.data['address'] = property.address;

        print("Property image is: ${item.data['imageUrl']}");
        print("Property image is: ${item.data['price']}");

        _results.add(item);
      } catch (e) {
        print('Error fetching property details for $propertyId: $e');
      }
    }

    _displayedResults = results;  // Assign to displayed results
    setState(() {
      _isDataLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
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
        title: Text(
          "Search",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: "Roboto",
            fontSize: 14.sp,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
        child: Column(
          children: [
            Container(
              height: 6.h, // Adjust this value as needed
              child: TextField(
                controller: _queryController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(fontSize: 12.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // Call the function to fetch properties
                      _fetchProperties();
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  _fetchProperties();
                },
              ),
            ),
            _displayedResults.isEmpty ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30.h,
                  ),
                  Icon(
                    Icons.search_off, // Replace with your preferred icon
                    size: 48.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    "No results found",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ):
            ListView.builder(
              shrinkWrap: true,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                try {
                  final item = _results[index];
                  final address = item.data['address'] ?? 'No Property';
                  final city = item.data['city'] ?? 'No Property';
                  final imageUrl = item.data['imageUrl'] ?? '';
                  final price = formatPrice(item.data['price']) ?? '';
                  final agentId = item.data['agentId'] ?? '';
                  final propertyId = item.data['propertyId'] ?? '';

                  return Card(
                    elevation: 2.0, // Add a slight shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      onTap: () async {
                        // Combine fetching property and agent details
                        final futures = [
                          _propertyRepo.getProperty(propertyId),
                          fetchAgentDetails(agentId),
                        ];
                        final results = await Future.wait(futures);

                        final property = results[0] as PropertyModel;
                        final agent = results[1] as AgentModel;

                        // Navigate to PropertyDetails
                        Get.to(() => PropertyDetails(agentDetails: agent, propertyDetails: property));
                      },
                      leading: Container(
                        width: 70.0,
                        height: 80.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.error),
                          )
                              : Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(
                        "$address, $city",
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          price
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      // Display a single loading indicator while fetching data
                    ),
                  );
                } on Exception catch (e) {
                  print('error: $e');
                  return Center(child: Text('Error displaying property'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String formatPrice(String price) {
    double value = double.parse(price);
    final formatCurrency = NumberFormat("#,##0", "en_US");
    return 'K${formatCurrency.format(value)}';
  }
}
