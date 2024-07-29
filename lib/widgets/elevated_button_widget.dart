import 'package:flutter/material.dart';

class ElevatedButtonWidget<T> extends StatelessWidget {
  const ElevatedButtonWidget({
    super.key,
    this.formKey,
    required this.controller,
    required this.onTap,
    this.isLoading = false,
    required this.buttonText,
  });

  final GlobalKey<FormState>? formKey;
  final T controller;
  final VoidCallback onTap;
  final bool isLoading;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          elevation: 2.5,
          shadowColor: const Color(0xff3B3C36),
          minimumSize: const Size.fromHeight(60),
          backgroundColor: const Color(0xff0071b9)),
      child: isLoading == true
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }
}
