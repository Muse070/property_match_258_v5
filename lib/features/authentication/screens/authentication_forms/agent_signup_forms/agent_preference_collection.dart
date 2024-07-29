
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/common_widgets/app_large_text.dart';
import 'package:property_match_258_v5/features/authentication/controllers/preferences_controller.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/agent_signup_forms/preference_pages/page_1.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/agent_signup_forms/preference_pages/page_2.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/agent_signup_forms/preference_pages/page_3.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/main_page.dart';

class AgentPreferences extends StatefulWidget {
  const AgentPreferences({super.key});

  @override
  State<AgentPreferences> createState() => _AgentPreferencesState();
}


class _AgentPreferencesState extends State<AgentPreferences> {
  List images = [
    "258_no_bg.png",
    "real_estate_svg.png",
    "house_key.png",
  ];
  List largeText = [
    "ZIEA Verification",
    "Subscription",
    "Welcome",
  ];

  int pages = 3;

  PageController _pageController = PageController(initialPage: 0);
  final controller = Get.put(PreferencesController());

  int _currentPage = 0;
  int? selectedValue;


  @override
  void initState() {
    super.initState();
    final preferencesController = Get.find<PreferencesController>();
    _pageController = preferencesController.pageController;
    _pageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    controller.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
          physics: const ClampingScrollPhysics(),
          controller: _pageController,
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          itemBuilder: (_, index) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                              _headerWidget(index),
                              Container(
                                margin: const EdgeInsets.only(left: 20, right: 20),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.735,
                                alignment: AlignmentDirectional.centerStart,
                                child: _buildPage(index),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 20, right: 20),
                                height: 60,
                                width: double.maxFinite,
                                child: _elevatedButton(_currentPage),
                              ),
                          const SizedBox(height: 40,),
                        ],
                          ),
                        ),
                      ),
                )
              ]
            );
          }),
    );
  }

  Widget _headerWidget(int index) {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * 0.15,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff34c0b3), Color(0xff0071b9)],
        ),
      ),
      child: SizedBox(
        child: AppLargeText(
          text: largeText[index],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
      // Updated key to ValueKey to ensure state management
        return const Page1(key: Key('page1'));
      case 1:
      // Updated key to ValueKey to ensure state management
        return const Page2(key: Key('page2'));
      case 2:
      // Updated key to ValueKey to ensure state management
        return const Page3(key: Key('page3'));
      default:
        return Container();
    }
  }

  Widget _elevatedButton(int currentPage) {
    return ElevatedButton(
      onPressed: () {
        if (currentPage == pages - 1) {
          Get.offAll(const MainPage());
        } else {
          _pageController.animateToPage(
              _pageController.page!.toInt() + 1,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInCubic);
        }
      },
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white70, backgroundColor: const Color(0xff0071b9), textStyle: const TextStyle(
              fontWeight: FontWeight.bold),
          // maximumSize: Size(double.maxFinite ),
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          )
      ),
      child: currentPage == images.length - 1?
      const Text("Get Started", style: TextStyle(fontSize: 18)): const Text("Next", style: TextStyle(fontSize: 18),)
    );
  }
}

