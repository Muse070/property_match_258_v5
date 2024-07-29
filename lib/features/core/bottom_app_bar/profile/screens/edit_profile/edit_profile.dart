import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/controllers/edit_profile_controller.dart';
import 'package:property_match_258_v5/model/user_models/agent_model.dart';
import 'package:property_match_258_v5/model/user_models/user_model.dart';
import 'package:property_match_258_v5/repository/user_repository/agent_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:property_match_258_v5/widgets/elevated_button_widget.dart';
import 'package:property_match_258_v5/widgets/text_field_widget.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../model/user_models/agent_model.dart';
import '../../../../../../model/user_models/client_model.dart';
import '../../../../../../repository/user_repository/agent_repository.dart';
import '../../../../../../repository/user_repository/user_repository.dart';
import '../../../../../../utils/pick_image.dart';
import '../../../../../../widgets/text_field_widget.dart';
import '../../controllers/edit_profile_controller.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({
    super.key,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _editProfileController = Get.find<EditProfileController>();
  final _userRepo = Get.find<UserRepository>();
  final _agentRepo = Get.find<AgentRepository>();

  Uint8List? _image;
  Uint8List? _agencyImage;

  @override
  Widget build(BuildContext context) {
    Rx<UserModel?> user = _userRepo.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: IconTheme(
            data: IconThemeData(
              size: 12.sp,
              color: Colors.white,
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: "Roboto",
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: Colors.black87,
      ),
      body: Container(
          margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.5.w),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: _userRepo.currentUser.value!.userType == 'client'
                ? Obx(() {
              return FutureBuilder<ClientModel>(
                  future: _userRepo
                      .getClient(_userRepo.currentUser.value!.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator()); // Show a loading indicator
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {

                      print("Preferences snapshot: ${snapshot.data!.preferences}");

                      // Initialize controllers after agent data is fetched (only if not already initialized)
                      if (!_editProfileController.isClientControllersInitialized) {
                        _editProfileController.initializeClientControllers(
                            snapshot.data!);
                      }
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            detailsClient(
                                _editProfileController.cPreferencesController,
                                snapshot.data!
                            ),
                            Text(
                              "Basic Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            EditProfileClientDetails(
                                firstName: _editProfileController
                                    .cFirstNameController,
                                lastName: _editProfileController
                                    .cLastNameController,
                                email: _editProfileController.cEmailController,
                                password: _editProfileController
                                    .cPasswordController,
                                phoneNumber: _editProfileController
                                    .cPhoneNumberController),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            Text(
                              "Address",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            EditProfileAddress(
                                address: _editProfileController
                                    .cAddressController,
                                city: _editProfileController.cCityController,
                                country: _editProfileController
                                    .cCountryController
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            Center(
                              child: ElevatedButtonWidget(
                                controller: _userRepo,
                                onTap: () async {



                                  final ClientModel cModel = ClientModel(
                                    email: _editProfileController.cEmailController.text,
                                    userType: _userRepo.currentUser.value!.userType,
                                    lastName: _editProfileController.cLastNameController.text,
                                    phoneNo: _editProfileController.cPhoneNumberController.text,
                                    password: _editProfileController.cPasswordController.text,
                                    id: _userRepo.currentUser.value!.id,
                                    firstName: _editProfileController.cFirstNameController.text,
                                    address: _editProfileController.cAddressController.text,
                                    city: _editProfileController.cCityController.text,
                                    country: _editProfileController.cCountryController.text,
                                    preferences: _editProfileController.cPreferencesController.text,
                                    imageUrl: _image != null && _image!.isNotEmpty  // Check if _image is valid
                                        ? await getImageFilePathFromDocByte(_image!)
                                        : _userRepo.currentUser.value!.imageUrl,
                                    // agencyImage: _editProfileController.agencyNameController.text,
                                    propertyIds: _userRepo.currentUser.value!.propertyIds,
                                  );



                                  try {
                                    // await _imageRepo.updateUserProfileImageUrl(imageUrl);
                                    // await _userRepo.updateUser(_user); // Update the user data in Firestore.



                                    await _userRepo.updateClientDetails(cModel);

                                    _userRepo.getUserDetails(_editProfileController.cEmailController.text);
                                    print("User from user repo ahs been updated");
                                    Get.snackbar('Success',
                                        'Your information has been updated',
                                        snackPosition:
                                        SnackPosition.BOTTOM);
                                  } catch (error) {
                                    // Handle specific errors or provide a generic error message
                                    if (error is FirebaseException) {
                                      if (error.code == 'not-found') {
                                        // Handle 'not found' error
                                        Get.snackbar(
                                            'Error', 'Document not found',
                                            snackPosition:
                                            SnackPosition.BOTTOM);
                                      } else if (error.code ==
                                          'permission-denied') {
                                        // Handle 'permission denied' error
                                        Get.snackbar(
                                            'Error', 'Permission denied',
                                            snackPosition:
                                            SnackPosition.BOTTOM);
                                      } else {
                                        // Handle other Firebase-related errors
                                        Get.snackbar('Error',
                                            'Something went wrong.',
                                            snackPosition:
                                            SnackPosition.BOTTOM);
                                      }
                                    } else {
                                      // Handle generic errors
                                      Get.snackbar(
                                          'Error', 'Unknown error.',
                                          snackPosition:
                                          SnackPosition.BOTTOM);
                                    }
                                  }
                                },
                                buttonText: "Update",
                              ),
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                          ]);
                    }
                  });
            })
                : Obx(() {
              return FutureBuilder<AgentModel>(
                  future: _agentRepo
                      .getAgent(_userRepo.currentUser.value!.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator()); // Show a loading indicator
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {

                      // Initialize controllers after agent data is fetched (only if not already initialized)
                      if (!_editProfileController.isAgentControllersInitialized) {
                        _editProfileController.initializeAgentControllers(
                            snapshot.data!);
                      }
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            detailsAgency(
                                _editProfileController.bioController,
                                _editProfileController.agencyNameController,
                                snapshot.data!
                            ),
                            Text(
                              "Basic Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            EditProfileClientDetails(
                                firstName: _editProfileController
                                    .firstNameController,
                                lastName: _editProfileController
                                    .lastNameController,
                                email: _editProfileController.emailController,
                                password: _editProfileController
                                    .passwordController,
                                phoneNumber: _editProfileController
                                    .passwordController),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            Text(
                              "Address",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp),
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            EditProfileAddress(
                                address: _editProfileController
                                    .addressController,
                                city: _editProfileController.cityController,
                                country: _editProfileController
                                    .countryController
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                            Center(
                              child: ElevatedButtonWidget(
                                controller: _userRepo,
                                onTap: () async {

                                  final AgentModel aModel = AgentModel(
                                    email: _editProfileController.emailController.text,
                                    userType: _userRepo.currentUser.value!.userType,
                                    lastName: _editProfileController.lastNameController.text,
                                    phoneNo: _editProfileController.phoneNumberController.text,
                                    password: _editProfileController.passwordController.text,
                                    id: _userRepo.currentUser.value!.id,
                                    firstName: _editProfileController.firstNameController.text,
                                    address: _editProfileController.addressController.text,
                                    city: _editProfileController.cityController.text,
                                    country: _editProfileController.countryController.text,
                                    bio: _editProfileController.bioController.text,
                                    imageUrl: _image != null && _image!.isNotEmpty  // Check if _image is valid
                                        ? await getImageFilePathFromDocByte(_image!)
                                        : _userRepo.currentUser.value!.imageUrl,
                                    // agencyImage: _editProfileController.agencyNameController.text,
                                    agencyName: _editProfileController.agencyNameController.text,
                                    propertyIds: _userRepo.currentUser.value!.propertyIds,
                                  );



                                  try {
                                    // await _imageRepo.updateUserProfileImageUrl(imageUrl);
                                    // await _userRepo.updateUser(_user); // Update the user data in Firestore.



                                    await _agentRepo.updateAgentDetails(aModel);

                                    _userRepo.getUserDetails(_editProfileController.emailController.text);

                                    Get.snackbar('Success',
                                        'Your information has been updated',
                                        snackPosition:
                                        SnackPosition.BOTTOM);
                                  } catch (error) {
                                    // Handle specific errors or provide a generic error message
                                    if (error is FirebaseException) {
                                      if (error.code == 'not-found') {
                                        // Handle 'not found' error
                                        Get.snackbar(
                                            'Error', 'Document not found',
                                            snackPosition:
                                            SnackPosition.BOTTOM);
                                      } else if (error.code ==
                                          'permission-denied') {
                                        // Handle 'permission denied' error
                                        Get.snackbar(
                                            'Error', 'Permission denied',
                                            snackPosition:
                                            SnackPosition.BOTTOM);
                                      } else {
                                        // Handle other Firebase-related errors
                                        Get.snackbar('Error',
                                            'Something went wrong.',
                                            snackPosition:
                                            SnackPosition.BOTTOM);
                                      }
                                    } else {
                                      // Handle generic errors
                                      Get.snackbar(
                                          'Error', 'Unknown error.',
                                          snackPosition:
                                          SnackPosition.BOTTOM);
                                    }
                                  }
                                },
                                buttonText: "Update",
                              ),
                            ),
                            SizedBox(
                              height: 1.5.h,
                            ),
                          ]);
                    }
                  });
            }),
          )),
    );
  }

  Column detailsAgency(TextEditingController bio,
      TextEditingController agencyName, AgentModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Column(
            children: [
              Stack(
                children: [
                  Obx(() { // Wrap with Obx to make it reactive to changes in _imageController.profilePic
                    final profilePicBytes = _editProfileController.profilePic
                        .value;

                    if (profilePicBytes != null && profilePicBytes
                        .isNotEmpty) { // Display new image if available
                      return CircleAvatar(
                        radius: 13.w,
                        backgroundImage: MemoryImage(
                            profilePicBytes), // Use MemoryImage for Uint8List
                      );
                    } else
                    if (_userRepo.currentUser.value!.imageUrl != null &&
                        _userRepo.currentUser.value!.imageUrl!.isNotEmpty
                        && profilePicBytes
                            .isEmpty) { // Display network image from the database
                      return CircleAvatar(
                        radius: 13.w,
                        backgroundImage: NetworkImage(_userRepo
                            .currentUser.value!.imageUrl!),
                      );
                    } else { // Display initials if no image available
                      return ProfilePicture(
                        name: user.firstName.isNotEmpty ? "${user
                            .firstName} ${user.lastName}" : "",
                        radius: 13.w,
                        fontsize: 18.sp,
                      );
                    }
                  }),
                  Positioned(
                    bottom: -1.h,
                    left: 13.w,
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
                style:
                TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 1.5.h,
        ),
        Text(
          "Profile Overview",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        SizedBox(
          height: 1.5.h,
        ),
        TextField(
          controller: agencyName,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            label: const Text("Agency Name"),
            // hintText: "Agency Name",
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
          controller: bio,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            label: Text("Bio"),
            hintText: "Enter your bio (max 150 characters)",
            hintStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.5.h),
                borderSide: const BorderSide(color: Colors.black)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.5.h),
                borderSide: const BorderSide(color: Colors.black)),
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
    );
  }


  Column detailsClient(TextEditingController preferences, ClientModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.w,
          child: Column(
            children: [
              Stack(
                children: [
                  Obx(() { // Wrap with Obx to make it reactive to changes in _imageController.profilePic
                    final profilePicBytes = _editProfileController.profilePic
                        .value;

                    if (profilePicBytes
                        .isNotEmpty) { // Display new image if available
                      return CircleAvatar(
                        radius: 13.w,
                        backgroundImage: MemoryImage(
                            profilePicBytes), // Use MemoryImage for Uint8List
                      );
                    } else
                    if (_userRepo.currentUser.value!.imageUrl != null &&
                        _userRepo.currentUser.value!.imageUrl!.isNotEmpty
                        && profilePicBytes
                            .isEmpty) { // Display network image from the database
                      print("My network image is: ${_userRepo.currentUser.value!.imageUrl}");
                      return CircleAvatar(
                        radius: 13.w,
                        backgroundImage: NetworkImage(_userRepo
                            .currentUser.value!.imageUrl!),
                      );
                    } else { // Display initials if no image available
                      return ProfilePicture(
                        name: user.firstName.isNotEmpty ? "${user
                            .firstName} ${user.lastName}" : "",
                        radius: 13.w,
                        fontsize: 18.sp,
                      );
                    }
                  }),
                  Positioned(
                    bottom: -1.h,
                    left: 13.w,
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
                style:
                TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 1.5.h,
        ),
        Text(
          "Profile Overview",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        SizedBox(
          height: 1.5.h,
        ),
        SizedBox(
          height: 1.5.h,
        ),
        TextFormField(
          maxLength: 150,
          // minLines: 1, //Normal textInputField will be displayed
          maxLines: 5,
          controller: preferences,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            label: const Text("Preferences"),
            hintText: "Enter your preferences (max 150 characters)",
            hintStyle: const TextStyle(color: Colors.black),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.5.h),
                borderSide: const BorderSide(color: Colors.black)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(1.5.h),
                borderSide: const BorderSide(color: Colors.black)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your preferences";
            }
            return null;
          },
        ),
        SizedBox(
          height: 1.5.h,
        ),
      ],
    );
  }

  void selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
      _editProfileController.profilePic.value = _image!;
    });
  }
}

class EditProfileAddress extends StatelessWidget {
  const EditProfileAddress({
    super.key,
    required this.address,
    required this.city,
    required this.country,
  });

  final TextEditingController address;
  final TextEditingController city;
  final TextEditingController country;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 0.5.h,
        ),
        TextBarWidget(
          textEditingController: address,
          isPassword: false,
          hintText: "Address",
          label: "Address",
          iconData: Icons.home,
          validatorError: "Please enter address",
        ),
        SizedBox(
          height: 1.5.h,
        ),
        TextBarWidget(
          textEditingController: city,
          isPassword: false,
          hintText: "City",
          label: "City",
          iconData: Icons.location_city_outlined,
          validatorError: "Please enter city",
        ),
        SizedBox(
          height: 1.5.h,
        ),
        TextBarWidget(
          textEditingController: country,
          isPassword: false,
          hintText: "Country",
          label: "Country",
          iconData: Icons.flag,
          validatorError: "Please enter country",
        ),
        SizedBox(
          height: 1.5.h,
        ),
      ],
    );
  }
}

class EditProfileClientDetails extends StatelessWidget {
  const EditProfileClientDetails({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
  });

  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(
        height: 0.5.h,
      ),
      TextBarWidget(
        textEditingController: firstName,
        label: "First Name",
        iconData: Icons.person_2_outlined,
        validatorError: "Please enter your first name",
        isPassword: false,
      ),
      SizedBox(
        height: 1.5.h,
      ),
      TextBarWidget(
        textEditingController: lastName,
        label: "Last Name",
        validatorError: "Please enter your last name",
        isPassword: false,
      ),
      SizedBox(
        height: 1.5.h,
      ),
      TextBarWidget(
        textEditingController: email,
        label: "Email",
        iconData: Icons.email_outlined,
        validatorError: "Please enter your email",
        isPassword: false,
      ),
      SizedBox(
        height: 1.5.h,
      ),
      TextBarWidget(
          textEditingController: password,
          label: "Password",
          validatorError: "Please enter your password",
          isPassword: true),
      SizedBox(
        height: 1.5.h,
      ),
      TextBarWidget(
          textEditingController: password,
          label: "Confirm Password",
          validatorError: "Please confirm your password",
          isPassword: true),
      SizedBox(
        height: 1.5.h,
      ),
      TextBarWidget(
        textEditingController: phoneNumber,
        label: "Phone Number",
        iconData: Icons.phone,
        validatorError: "Please confirm your phone number",
        isPassword: false,
      ),
      SizedBox(
        height: 1.5.h,
      ),
    ]);
  }
}
