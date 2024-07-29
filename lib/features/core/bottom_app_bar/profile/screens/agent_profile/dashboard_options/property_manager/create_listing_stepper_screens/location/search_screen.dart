import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:sizer/sizer.dart';
import 'package:uuid/uuid.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final _mapController = Get.find<ListingController>();

  List<dynamic> listForPlaces = [];
  String tokenForSession = '34468';
  var uuid = const Uuid();


  late TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _search.addListener(() {
      onModify();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _makeSuggestion(String input) async {
    String googlePlacesApiKey = 'AIzaSyD-xH95SumIGirRzbz2qn7Mu2twy0E7a6E';
    String groundURL ='https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$groundURL?input=$input&key=$googlePlacesApiKey&sessiontoken=$tokenForSession'
        '&components=country:zm';

    var responseResult = await http.get(Uri.parse(request));

    var resultData = responseResult.body.toString();

    print('Result Data');
    print(resultData);

    if(responseResult.statusCode == 200) {
      if (mounted) {
        setState(() {
          listForPlaces =
          jsonDecode(responseResult.body.toString()) ['predictions'];
        });
      }
    } else {
      throw Exception("Something happened. Try again!");
    }
  }

  void onModify() {
    if (tokenForSession == null) {
      setState(() {
        tokenForSession = uuid.v4();
      });
    }
    _makeSuggestion(_search.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: IconTheme(
            data: IconThemeData(
              size: 3.h,
              color: Colors.black87,
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text("Search"),
      ),
      body: Container(
        height: 100.h,
        width: 100.w,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 3.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 100.w, // Change this value to your desired width
                height: 6.5.h, // Change this value to your desired height
                child: TextFormField(
                  controller: _search,
                  decoration: InputDecoration(
                    hintText: "Search Places",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.w),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _search.clear();
                      },
                      icon: const Icon(Icons.cancel_outlined),
                    )
                  ),
          
                ),
              ),
              ListView.builder(
                itemCount: listForPlaces.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      if (_search.text.isEmpty) {
                        listForPlaces.clear();
                      }

                      List<String> addressParts = listForPlaces[index]['description'].split(', ');

                      String address = '';
                      String city = '';
                      String country = '';

                      // Extract city and province from the address
                      if (addressParts.isNotEmpty) {
                        if (addressParts.length >= 2) {
                          country = addressParts.last;
                          city = addressParts[addressParts.length - 2];
                          address = addressParts.sublist(0, addressParts.length - 2).join(', ');
                        } else if (addressParts.length == 1) {
                          country = addressParts[0];
                        }

                        // Update the address in the mapController
                        _mapController.updateAddress(country, city, address);

                        print("Now going back: $address, $city, $country");
                        Get.back();

                        locationFromAddress(listForPlaces[index]
                        ['description']).then((locations) {
                          _mapController.updateLocation(
                              locations.last.latitude,
                              locations.last.longitude
                          );
                        }).catchError((error) {
                          print("An error occurred: $error");
                        });

                      } else {
                        print("The address is empty");
                      }
                    },
                    title: Text(listForPlaces[index]['description']),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
