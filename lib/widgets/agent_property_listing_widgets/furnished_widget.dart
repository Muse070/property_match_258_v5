import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FurnishedSelectionRow extends StatefulWidget {
  final ValueChanged<bool> onFurnishedSelected;
  final bool initialValue;

  const FurnishedSelectionRow({
    Key? key,
    required this.onFurnishedSelected,
    this.initialValue = false,
  }) : super(key: key);

  @override
  _FurnishedSelectionRowState createState() => _FurnishedSelectionRowState();
}

class _FurnishedSelectionRowState extends State<FurnishedSelectionRow> {
  bool? isFurnished;

  @override
  void initState() {
    super.initState();
    isFurnished = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dropdown on the left
        DropdownButton<bool>(
          value: isFurnished,
          onChanged: (bool? newValue) {
            setState(() {
              isFurnished = newValue;
              widget.onFurnishedSelected(newValue!);
            });
          },
          items: <bool>[true, false]
              .map<DropdownMenuItem<bool>>((bool value) {
            return DropdownMenuItem<bool>(
              value: value,
              child: Text(value ? 'Furnished' : 'Unfurnished'),
            );
          }).toList(),
          underline: Container(), // Remove default underline
        ),
      ],
    );
  }
}
