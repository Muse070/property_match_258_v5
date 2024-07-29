import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_match_258_v5/features/authentication/controllers/agent_controllers/agent_signup_controller.dart';
import 'package:property_match_258_v5/features/authentication/controllers/client_controllers/client_signup_controller.dart';
import 'package:sizer/sizer.dart';

import '../../../../../utils/pick_image.dart';

class ClientProfileForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const ClientProfileForm({required Key key, required this.formKey})
      : super(key: key);

  @override
  State<ClientProfileForm> createState() => _ClientProfileFormState();
}

class _ClientProfileFormState extends State<ClientProfileForm> {
  final _clientSignUpController = Get.find<ClientSignUpController>();

  Uint8List? _image;

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image = im;
        _clientSignUpController.profilePic = _image!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
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
          SizedBox(
            height: 1.5.h,
          ),
          TextFormField(
            maxLength: 150,
            // minLines: 1, //Normal textInputField will be displayed
            maxLines: 5,
            controller: _clientSignUpController.bio,
            decoration: InputDecoration(
              label: const Text("Preferences"),
              hintText: "We're excited to help! Share what you're looking for - a home, land, commercial or industrial property. Remember, you can refine this anytime. (max 150 characters)",
              hintStyle: const TextStyle(
                  color: Colors.black54,
                fontWeight: FontWeight.w400

              ),
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
                return "Please share your preferences";
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
