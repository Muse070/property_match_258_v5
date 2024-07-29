import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class CustomMarker extends StatelessWidget {
  final RxString price;
  const CustomMarker({super.key, required this.price});

  String _modifyPrice() {
    double priceValue = double.tryParse(price.value) ?? 0.0;
    if (priceValue >= 1000 && priceValue < 1000000) {
      return "K${(priceValue / 1000).toStringAsFixed(2)}K";
    } else if (priceValue >= 1000000 && priceValue < 1000000000) {
      return "K${(priceValue / 1000000).toStringAsFixed(2)}M";
    } else if (priceValue >= 1000000000) {
      return "K${(priceValue / 1000000000).toStringAsFixed(2)}B";
    } else {
      return "K${priceValue.toStringAsFixed(2)}";
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 7.h,
      width: 7.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
           Align(
            alignment: Alignment.bottomCenter,
            child: Icon(
              Icons.arrow_drop_down,
              color: Colors.red.withOpacity(0.75),
              size: 18.sp,
              // Add a shadow to the icon
              shadows: const [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black,
                  offset: Offset(5.0, 5.0),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 1.5.h),
            padding: EdgeInsets.all(1.5.w),
            // height: 7.5.h,
            // width: 15.5.w,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.75),
              borderRadius: BorderRadius.circular(10), // Set the radius here
            ),
            child: Obx(() => Text(
                _modifyPrice(),
                style: TextStyle(
                  color: Colors.white,
                  // Increase the font size
                  fontSize: 8.sp,
                  // Add a shadow to the text
                  shadows: const [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
