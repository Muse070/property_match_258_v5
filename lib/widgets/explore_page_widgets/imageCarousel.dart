import 'package:another_carousel_pro/another_carousel_pro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class ImageCarousel extends StatelessWidget {
  final double height;
  final double width;
  const ImageCarousel({
    super.key,
    required this.imageList, required this.height, required this.width,
  });

  final List<String> imageList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      width: width.w,
      child: AnotherCarousel(
        images: imageList.map((url) =>
            Image.network(
              url,
              fit: BoxFit.fitWidth,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                  ),
                );
              },
            )
        ).toList(),
        dotSize: 4.sp,
        dotSpacing: 3.5.w,
        dotColor: Colors.white,
        dotIncreaseSize: 2.sp,
        indicatorBgPadding: 2.h,
        borderRadius: false,
        autoplay: false,
      ),
    );
  }
}
