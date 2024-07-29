import 'package:flutter/material.dart';

class CurrencySelectionWidget extends StatefulWidget {
  final ValueChanged<String> onCurrencySelected;
  final String initialCurrency; // The initially selected currency

  const CurrencySelectionWidget({
    Key? key,
    required this.onCurrencySelected,
    this.initialCurrency = 'USD',
  }) : super(key: key);

  @override
  _CurrencySelectionWidgetState createState() => _CurrencySelectionWidgetState();
}

class _CurrencySelectionWidgetState extends State<CurrencySelectionWidget> {
  String? selectedCurrency; // Store the currently selected currency

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.initialCurrency; // Initialize with the initialCurrency
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton<String>(
          value: selectedCurrency,
          onChanged: (String? newValue) {
            setState(() {
              selectedCurrency = newValue;
              widget.onCurrencySelected(newValue!); // Notify the parent
            });
          },
          items: <String>['USD', 'ZMW'] // Add your currency options here
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              key: ValueKey(value), // Add unique keys
              value: value,
              child: Text(value),
            );
          }).toList(),
          underline: Container(), // Remove default underline
        ),
      ],
    );
  }
}
