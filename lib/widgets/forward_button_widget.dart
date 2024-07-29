import 'package:flutter/material.dart';

class ForwardButton extends StatelessWidget {
  final Function() onTap;
  Color? color;
  ForwardButton({
    super.key,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
