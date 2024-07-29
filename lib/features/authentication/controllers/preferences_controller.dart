import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/client_signup_forms/preference_pages/client_page_1.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/client_signup_forms/preference_pages/client_page_2.dart';
import 'package:property_match_258_v5/features/authentication/screens/authentication_forms/client_signup_forms/preference_pages/client_page_3.dart';

class PreferencesController extends GetxController {
  static PreferencesController get instance => Get.find();

  final PageController pageController = PageController(initialPage: 0);
  final page1Key = GlobalKey<ClientPage1State>();
  final page2Key = GlobalKey<ClientPage2State>();
  final page3Key = GlobalKey<ClientPage3State>();
}