import 'dart:core';

import 'package:flutter/material.dart';

class TextBarWidget extends StatefulWidget {
  final TextEditingController textEditingController;
  String? hintText;
  IconData? iconData;
  bool isPassword = false;
  bool? isImportant;
  String? validatorError;
  String? label;

  TextBarWidget({
    required this.textEditingController,
    this.hintText,
    this.iconData,
    this.isImportant,
    this.validatorError,
    required this.isPassword,
    this.label,
    super.key,
  });

  @override
  State<TextBarWidget> createState() => _TextBarWidgetState();
}

class _TextBarWidgetState extends State<TextBarWidget> {

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.textEditingController,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        label: Text(widget.label ?? ""),
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Colors.black
        ),
        contentPadding: const EdgeInsets.all(10.9),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.black)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.black)
        ),
        suffixIcon: widget.isPassword == true ?
        const Icon(Icons.remove_red_eye) :
        Icon(widget.iconData ?? Icons.done),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.validatorError;
        }
        return null;
      },
      obscureText: widget.isPassword,
    );
  }
}
