import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'dashboard_options/property_manager/property_manager.dart';

class Dashboard extends StatefulWidget {
  final int? numOfListings;
  const Dashboard({super.key, required this.numOfListings});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin {

  List<Widget> get icons =>
      [
        const FaIcon(FontAwesomeIcons.calendarCheck), // calendar icon
        const FaIcon(FontAwesomeIcons.userGroup), // person_2 icon
        const FaIcon(FontAwesomeIcons.copy), // folder_copy icon
        const FaIcon(FontAwesomeIcons.commentDots), // message icon
      ];



  Widget _feature(Size size,
      double height,
      double width,
      Widget icon, // Change FaIcon to Widget
      String title,
      double iconSize,
      Widget page,
      ) {
    return GestureDetector(
      onTap: () {
        Get.to(() => page);
      },
      child: SizedBox(
        height: height,
        width: width,
        child: Card(
            color: Colors.white,
            elevation: 0.2,
            shadowColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Center(
              child: ListTile(
                leading: CircleAvatar(
                  radius: 6.w,
                  backgroundColor: Colors.black87,
                  child: FaIcon(
                    FontAwesomeIcons.house,
                    color: Color(0xFF80CBC4),
                    size: 14.sp,
                  ),
                ),
                title: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Roboto'),
                ),
                trailing: TextButton(
                  onPressed: () {
                    Get.to(() => page);
                  },
                  child: const Text(
                    "View All",
                    style: TextStyle(
                      color: Color(0xFF008080),
                    ),
                  ),
                ),
                titleTextStyle: const TextStyle(),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery
        .of(context)
        .size;
    double rectHeight = 12.h;
    double rectWidth = 100.w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _feature(
          size,
          rectHeight,
          rectWidth,
          const FaIcon(FontAwesomeIcons.houseUser),
          "Manage Listings",
          20.sp,
          const PropertyManager(),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
