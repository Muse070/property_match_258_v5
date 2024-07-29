
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/common_widgets/app_large_text.dart';
import 'package:property_match_258_v5/features/authentication/controllers/preferences_controller.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/client_signup_forms/preference_pages/client_page_1.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/client_signup_forms/preference_pages/client_page_2.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/client_signup_forms/preference_pages/client_page_3.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/main_page.dart';

class PreferenceCollection extends StatefulWidget {
  const PreferenceCollection({super.key});

  @override
  State<PreferenceCollection> createState() => _PreferenceCollectionState();
}

class _PreferenceCollectionState extends State<PreferenceCollection> {
  List images = [
    "258_no_bg.png",
    "real_estate_svg.png",
    "house_key.png",
  ];
  List largeText = [
    "Property Type",
    "Location",
    "Welcome",
  ];


  PageController _pageController = PageController(initialPage: 0);
  final controller = Get.put(PreferencesController());

  int _currentPage = 0;

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

  // void _saveState() {
  //   final currentPage = _pageController.page!.toInt();
  //   switch (currentPage) {
  //     case 0:
  //       (controller.page1Key.currentState)?.saveState();
  //       break;
  //     case 1:
  //       (controller.page2Key.currentState)?.saveState();
  //       break;
  //     case 2:
  //       (controller.page3Key.currentState)?.saveState();
  //       break;
  //   }
  // }

  // void _changePage(int newIndex) {
  //   _saveState();
  //   _currentPage = newIndex;
  //
  //   WidgetsBinding.instance!.addPostFrameCallback((_) {
  //     _pageController.jumpToPage(newIndex);
  //   });
  // }


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
                              _header(index),
                              Container(
                                margin: const EdgeInsets.only(left: 20, right: 20),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.735,
                                alignment: AlignmentDirectional.centerStart,
                                child: _buildPage(index)
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 20, right: 20),
                                height: 60,
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_currentPage == images.length - 1) {
                                      Get.offAll(const MainPage());
                                    } else {
                                      _currentPage++;
                                      _pageController.animateToPage(
                                          _currentPage,
                                          duration: const Duration(
                                              milliseconds: 500),
                                          curve: Curves.easeInCubic
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white70, backgroundColor: const Color(0xff0071b9), textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      )
                                  ),
                                  child: _currentPage == images.length - 1 ?
                                  const Text("Get Started",
                                      style: TextStyle(fontSize: 18)) :
                                  const Text(
                                    "Next", style: TextStyle(fontSize: 18),),
                                ),
                              ),
                              const SizedBox(height: 40,),
                            ]
                        ),
                      )
                  )
              ),
            ]);
      })
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
      // Updated key to ValueKey to ensure state management
        return const ClientPage1(key: Key('page1'));
      case 1:
      // Updated key to ValueKey to ensure state management
        return const ClientPage2(key: Key('page2'));
      case 2:
      // Updated key to ValueKey to ensure state management
        return const ClientPage3(key: Key('page3'));
      default:
        return Container();
    }
  }

  Widget _header(int index) {
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
        width: 300,
        child: AppLargeText(
            text: largeText[index]
        ),
      ),
    );
  }
}

