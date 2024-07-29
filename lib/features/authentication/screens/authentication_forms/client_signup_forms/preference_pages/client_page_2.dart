import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ClientPage2 extends StatefulWidget {
  @override
  final Key key;
  const ClientPage2({required this.key}) : super(key: key);

  @override
  State<ClientPage2> createState() => ClientPage2State();
}

class ClientPage2State extends State<ClientPage2> with AutomaticKeepAliveClientMixin{
  List<String> selectedLocations = [];
  final TextEditingController _searchController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 250,
              child: Text(
                "Please enter your preferred location(s).",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40,),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: _locationSearchBar(_searchController, "e.g Lusaka, Kitwe, Roma"),
          ),
          const SizedBox(height: 40,),
      Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.30,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(width: 2.5, color: Colors.black),
        ),
        child: Wrap(
            spacing: 15, // Adjust the spacing between chips
            runSpacing: 5, // Adjust the spacing between chip rows
            children: selectedLocations.map((String propertyType) {
              return Chip(
                side: const BorderSide(
                    color: Color(0xff0071b9)
                ),
                label: Text(propertyType),
                onDeleted: () {
                  setState(() {
                    selectedLocations.remove(propertyType);
                  });
                },
              );
            }).toList(),
          ),
        )
        ],
      ),
    );
  }

  Widget _locationSearchBar(TextEditingController searchController, String hintText,) {
    return TextField(
      onSubmitted: (String location){
        setState(() {
          if (selectedLocations.length <= 7) {
            final formattedLocation = location.trim().capitalizeFirst;
            if (!selectedLocations.contains(formattedLocation)) {
              selectedLocations.add(formattedLocation!);
              searchController.clear();
            }
          }
        });
      },
      controller: searchController,
      cursorColor: Colors.black,
      decoration: InputDecoration(
          focusColor: Colors.black,
          fillColor: Colors.black,
          hintText: hintText,
          contentPadding: const EdgeInsets.all(10.9),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(color: Colors.black)
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(color: Colors.black)
          ),
      ),
    );
  }

  void saveState() {
    _formKey.currentState?.save();
  }
}
