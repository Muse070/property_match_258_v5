import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/common_widgets/app_large_text.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/main_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List images = [
    "258_no_bg.png",
    "real_estate_svg.png",
    "house_key.png",
  ];
  List largeText = ["Your Journey To Find The Perfect Home Begins With Property Match ",
    "Purchase, Rent Or Manage Your Estate With Ease",
    "Unlock New Possibilities As A Real Estate Agent",];
  List mediumText = ["Home", "With Ease", "Possibilities"];
  List smallText = ["Explore our extensive property catalog with ease as you embark on a journey to find your perfect estate.",
      "Discover your personal haven that perfectly aligns with your unique taste.",
      "Uncover a world of diverse real estate options and seize countless opportunities in the market."];

  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.toInt();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: images.length,
        itemBuilder: (_, index) {
          return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 200,
                          child: AppLargeText(
                              text: largeText[index]
                          ),
                        ),
                        Column(
                            children: List.generate(3, (indexDots) {
                              return Container(
                                  margin: const EdgeInsets.only(bottom: 2),
                                  width: 8,
                                  height: index == indexDots ? 25 : 8,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          8),
                                      color: index == indexDots ? const Color(
                                          0xFF100c08) : const Color(0xFF100c08)
                                          .withOpacity(0.3)
                                  )
                              );
                            })

                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    margin: const EdgeInsets.only(left: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == images.length - 1) {
                          Get.offAll(const MainPage());
                        } else {
                          _pageController.animateToPage(
                              _pageController.page!.toInt() + 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInCubic);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white70, backgroundColor: Colors.black, textStyle: const TextStyle(
                              fontWeight: FontWeight.bold),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          )
                      ),
                      child: _currentPage == images.length - 1?
                       const Text("Get Started"): const Text("Next"),
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    alignment: AlignmentDirectional.centerStart,
                    height: 200,
                    margin: const EdgeInsets.only(
                        top: 50, left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      backgroundBlendMode: BlendMode.overlay,
                        borderRadius: BorderRadius.circular(10),
                        border: _currentPage == 0
                            ? Border.all(
                            color: Colors.black,
                            width: 2.0
                        )
                            : null,
                        image: DecorationImage(
                          alignment: Alignment.center,
                            image: AssetImage(
                                "img/" + images[index]
                            ),)
                    ),
                  ),
                ]
            ),
          );
        }),
    );
  }
}

