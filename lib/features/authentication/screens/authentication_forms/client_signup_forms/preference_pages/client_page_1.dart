import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ClientPage1 extends StatefulWidget {
  const ClientPage1({super.key});

  @override
  ClientPage1State createState() => ClientPage1State();
}

class ClientPage1State extends State<ClientPage1> with AutomaticKeepAliveClientMixin {

  String selectedValue = "House";
  List<String> propertyTypes = [
    'House',
    'Apartment',
    'Condo',
    'Land',
    'Commercial',
    'Boarding House',
    'Single Room'
  ];
  List<String> selectedPropertyTypes = [];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Check if the selectedValue is still present in propertyTypes
    if (!propertyTypes.contains(selectedValue)) {
      // Handle the case where the selectedValue is not available
      // Set a default value or perform any other necessary action
      selectedValue = propertyTypes.first;
    }

    if (kDebugMode) {
      print(selectedPropertyTypes);
    }
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 250,
              child: Text(
                "What type of property are you looking for?",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
              child: _dropDown(propertyTypes)
          ),
          const SizedBox(height: 40),
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
              spacing: 27, // Adjust the spacing between chips
              runSpacing: 5, // Adjust the spacing between chip rows
              children: selectedPropertyTypes.map((String propertyType) {
                return Chip(
                  side: const BorderSide(
                      color: Color(0xff0071b9)
                  ),
                  label: Text(propertyType),
                  onDeleted: () {
                    setState(() {
                      selectedPropertyTypes.remove(propertyType);
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropDown(List<String> items) {
    return DropdownButton<String>(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      value: selectedValue,
      onChanged: (String? newValue) {
        setState(() {
          if (newValue != null) {
            if (!selectedPropertyTypes.contains(newValue)) {
              selectedPropertyTypes.add(newValue);
            }
            selectedValue = newValue;
          }
        });
      },
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  void saveState() {
    _formKey.currentState?.save();
  }

  @override
  void didUpdateWidget(covariant ClientPage1 oldWidget) {
    // This is called when the parent widget rebuilds
    // Use this method to restore the state after a rebuild

    // Check if the selectedValue is present in propertyTypes
    if (!propertyTypes.contains(selectedValue)) {
      // Handle the case where the selectedValue is not available after a rebuild
      // You can set a default value or perform any other necessary action
      selectedValue = propertyTypes.first;
    }

    // Ensure that selectedPropertyTypes contains only valid values
    selectedPropertyTypes.removeWhere((type) => !propertyTypes.contains(type));

    super.didUpdateWidget(oldWidget);
  }
}
