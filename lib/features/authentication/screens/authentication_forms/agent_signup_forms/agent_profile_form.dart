import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_match_258_v5/features/authentication/controllers/agent_controllers/agent_signup_controller.dart';
import 'package:sizer/sizer.dart';

import '../../../../../utils/pick_image.dart';

class AgentProfileForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const AgentProfileForm({required Key key, required this.formKey})
      : super(key: key);

  @override
  State<AgentProfileForm> createState() => _AgentProfileFormState();
}

class _AgentProfileFormState extends State<AgentProfileForm> {
  final _agentSignupController = Get.find<AgentSignUpController>();

  Uint8List? _image;
  Uint8List? _agencyImage;

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image = im;
        _agentSignupController.profilePic = _image!;
      });
    }
  }

  void selectAgencyImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    if (im != null) {
      setState(() {
        _agencyImage = im;
        _agentSignupController.agencyPic = _agencyImage!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          SizedBox(
            width: 100.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                          radius: 5.h,
                          backgroundImage: MemoryImage(_image!),
                        )
                            : CircleAvatar(
                          radius: 5.h,
                          backgroundColor: Colors.black87,
                          child: Icon(
                            Icons.person,
                            color: Color(0xFF80CBC4),
                            size: 3.h,
                          ),
                        ),
                        Positioned(
                          bottom: -1.h,
                          left: 12.w,
                          child: IconButton(
                            onPressed: () {
                              selectImage();
                            },
                            icon: const Icon(
                              Icons.add_a_photo,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "Add Profile Photo",
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Stack(children: [
                      _agencyImage != null
                          ? CircleAvatar(
                        radius: 5.h,
                        backgroundImage: MemoryImage(_agencyImage!),
                      )
                          : CircleAvatar(
                        radius: 5.h,
                        backgroundColor: Colors.black87,
                        child: Icon(
                          Icons.business,
                          color: Color(0xFF80CBC4),
                          size: 3.h,
                        ),
                      ),
                      Positioned(
                        bottom: -1.h,
                        left: 12.w,
                        child: IconButton(
                          onPressed: () {
                            selectImage();
                          },
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ]),
                    const Text("Add Agency Logo"),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 1.5.h,
          ),
          TextField(
            decoration: InputDecoration(
              label: Text("Agency Name"),
              // hintText: "Bio",
              hintStyle: const TextStyle(color: Colors.black),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(1.5.h),
                  borderSide: const BorderSide(color: Colors.black)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(1.5.h),
                  borderSide: const BorderSide(color: Colors.black)),
            ),
          ),
          SizedBox(
            height: 1.5.h,
          ),
          TextFormField(
              maxLength: 150,
              // minLines: 1, //Normal textInputField will be displayed
              maxLines: 5,
              controller: _agentSignupController.aBio,
              decoration: InputDecoration(
                label: Text("Bio"),
                hintText: "Enter your bio (max 150 characters)",
                hintStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1.5.h),
                    borderSide: const BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(1.5.h),
                    borderSide: const BorderSide(color: Colors.black)
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a bio";
                }
                return null;
              },
          ),
          SizedBox(
            height: 1.5.h,
          ),
        ],
      ),
    );
  }
}
