import 'package:flutter/material.dart';
import 'app_text.dart';

class ResponsiveButton extends StatelessWidget {
  bool? isResponsive;
  double? width;
  ResponsiveButton({super.key,
    this.width=120,
    this.isResponsive=false});


  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        width: isResponsive==true?double.maxFinite:width,
        height: 60,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF100c08)
        ),
        child: Row(
          mainAxisAlignment: isResponsive==true?MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
          children: [
            isResponsive==true?Container(margin:const EdgeInsets.only(left: 20),
            child: AppText(text: "Book House Now", color: Colors.white,)):Container(),
            Image.asset("img/button-one.png")
          ]
        )
      ),
    );
  }
}
