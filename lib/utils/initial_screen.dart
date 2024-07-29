import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../features/authentication/screens/authentication_forms/auth_login.dart';
import '../features/authentication/screens/mail_verification/mail_verification.dart';
import '../features/core/bottom_app_bar/main_page.dart';
import '../repository/authentication_repository/authentication_repository.dart';
import 'local_storage.dart';

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthenticationRepository>();
    final user = authRepo.currentUser;

    if (user == null) {
      return const AuthLogin();
    } else {
      if (user.emailVerified) {
        return FutureBuilder(
          future: TLocalStorage.init(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const MainPage();
            } else {
              return const CircularProgressIndicator();
            }
          },
        );
      } else {
        return MailVerification();
      }
    }
  }
}
