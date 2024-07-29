import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SelectableContainer extends StatelessWidget {
  final String option;
  final IconData icon;
  final String selectedOption;
  final Function(String) onContainerTap;

  const SelectableContainer({
    super.key,
    required this.option,
    required this.icon,
    required this.selectedOption,
    required this.onContainerTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = option == selectedOption;

    return GestureDetector(
      onTap: () => onContainerTap(option),
      child: Container(
        height: 8.h,
        width: 12.5.h,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0XFF80CBC4) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3), // Border only for unselected items
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 3.0,
              blurRadius: 6.0,
              offset: const Offset(0, 3),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black87,
              size: 20.sp,
            ),
            Text(
              option,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
