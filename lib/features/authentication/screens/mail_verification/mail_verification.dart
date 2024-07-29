import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/features/authentication/controllers/mail_verification_controller.dart';
import 'package:property_match_258_v5/repository/authentication_repository/authentication_repository.dart';

class MailVerification extends StatelessWidget {
  MailVerification({super.key});

  bool isEmailVerified = false;

  final _auth = Get.find<AuthenticationRepository>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MailVerificationController());
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 60, left: 20, right: 20, bottom: 40
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mail_outline, size: 100,),
              const SizedBox(height: 40,),
              Text("Email Verification", style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 40,),
              SizedBox(
                width: 200,
                child: OutlinedButton(onPressed: () =>
                    controller.manuallyCheckEmailVerificationStatus(),
                    child: const Text("Continue")
                )
              ),
              const SizedBox(height: 40,),
              TextButton(
                  onPressed: () => controller.sendVerificationEmail(),
                  child: const Text("Resend Email Link"),
              ),
              TextButton(
                  onPressed: () => _auth.logout(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_left),
                      SizedBox(width: 5,),
                      Text("back to login")
                    ],
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
