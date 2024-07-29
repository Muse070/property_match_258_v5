import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class RadioButtonWidget extends StatefulWidget {
  final RxString selectedStatus;
  final Function(String) updateStatus;

  const RadioButtonWidget({
    Key? key,
    required this.selectedStatus,
    required this.updateStatus,
  }) : super(key: key);

  @override
  _RadioButtonWidgetState createState() => _RadioButtonWidgetState();
}

class _RadioButtonWidgetState extends State<RadioButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        Radio<String>(
          value: 'For Sale',
          groupValue: widget.selectedStatus.value,
          onChanged: (value) {
            setState(() {
              widget.updateStatus(value!);
            });
          },
        ),
        const Text('For Sale'),
        const SizedBox(width: 16), // Add spacing between radio buttons
        Radio<String>(
          value: 'For Rent',
          groupValue: widget.selectedStatus.value,
          onChanged: (value) {
            setState(() {
              widget.updateStatus(value!);
            });
          },
        ),
        const Text('For Rent'),
      ],
    ));
  }
}
