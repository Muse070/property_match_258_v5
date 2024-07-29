import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/controllers/favoritesController/favorites_controller.dart';
import 'package:property_match_258_v5/features/authentication/controllers/agent_controllers/agent_signup_controller.dart';
import 'package:property_match_258_v5/features/authentication/controllers/client_controllers/client_signup_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/home/controllers/home_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/main_page.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_profile_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/property_type_controllers/listing_controller.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/user_controller.dart';
import 'package:property_match_258_v5/firebase_options.dart';
import 'package:property_match_258_v5/repository/authentication_repository/authentication_repository.dart';
import 'package:property_match_258_v5/repository/chat_repository/chat_repository.dart';
import 'package:property_match_258_v5/repository/image_repository/image_repository.dart';
import 'package:property_match_258_v5/repository/properties_repository/property_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/agent_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:sizer/sizer.dart';

import 'controllers/propert_controller/property_controller.dart';
import 'features/authentication/screens/authentication_forms/auth_login.dart';
import 'features/authentication/screens/mail_verification/mail_verification.dart';
import 'features/core/bottom_app_bar/profile/controllers/property_type_controllers/commercial_controller.dart';
import 'features/core/bottom_app_bar/profile/controllers/property_type_controllers/industrial_controller.dart';
import 'features/core/bottom_app_bar/profile/controllers/property_type_controllers/land_controller.dart';
import 'features/core/bottom_app_bar/profile/controllers/property_type_controllers/residential_controllers.dart';
import 'model/user_models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print("duplicate app: $e");
    } else {
      print("Error on initialization: $e");
      // Handle other Firebase initialization errors
    }
  }  // await GetStorage.init();

  Get.put(AuthenticationRepository());
  Get.put(PropertyRepository());
  Get.put(PropertyController());
  Get.put(UserRepository());
  Get.put(AgentRepository());
  Get.put(ImageRepository());
  Get.put(UserController());
  Get.put(EditProfileController());
  Get.put(ClientSignUpController());
  Get.put(AgentSignUpController());
  // Get.put(GetUserController());
  await prefetchUserData();

  runApp(const MyApp());
}

Future<void> prefetchUserData() async {
  final auth = Get.find<AuthenticationRepository>();
  final db = FirebaseFirestore.instance;

  User? user = auth.firebaseUser.value;
  if (user != null) {
    var snapshot = await db
        .collection("clients")
        .where("Email", isEqualTo: user.email)
        .get();

    if (snapshot.docs.isEmpty) {
      snapshot = await db
          .collection("agents")
          .where("Email", isEqualTo: user.email)
          .get();
    }

    if (snapshot.docs.isNotEmpty) {
      final userData =
          snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;

      Get.put<UserModel>(userData, permanent: true);
    }
  }
  Get.put(AgentRepository());
  Get.put(ChatRepository());
  Get.put(ListingController());
  Get.put(FavoriteController());
  Get.put(ResidentialController());
  Get.put(CommercialController());
  Get.put(IndustrialController());
  Get.put(LandController());
  Get.put(AgentRepository());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    final userRepository = Get.find<UserRepository>();
    userRepository.checkLoggedInUser();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.black, // Or your desired color
              systemNavigationBarDividerColor: Colors.black
            // Add other systemNavigationBar properties you want to customize here
          ),
          child: Sizer(builder: (context, orientation, deviceType) {
            return GetMaterialApp(
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff3B3C36)),
                useMaterial3: true,
              ),
              initialRoute:
              AuthenticationRepository.instance.setInitialScreen(),
              getPages: [
                GetPage(name: '/', page: () => const AuthLogin()),
                GetPage(name: '/mainPage', page: () => const MainPage()),
                GetPage(
                    name: '/mailVerification', page: () => MailVerification()),
                // Add your other GetPages here
              ],
            );
          }),
        );
      },
    );
  }
}
