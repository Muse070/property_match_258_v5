import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/edit_profile/edit_profile.dart';
import 'package:property_match_258_v5/repository/properties_repository/property_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../model/property_models/property_model.dart';
import '../../../../../../model/user_models/agent_model.dart';
import '../../../../../../model/user_models/user_model.dart';
import '../../../../../../repository/chat_repository/chat_repository.dart';
import '../../../../pages/chat_page.dart';

class AgentProfilePage extends StatefulWidget {
  const AgentProfilePage({super.key});

  @override
  State<AgentProfilePage> createState() => _AgentProfilePageState();
}

class _AgentProfilePageState extends State<AgentProfilePage>
    with TickerProviderStateMixin {
  final _userRepo = Get.find<UserRepository>();
  final _propertyController = Get.find<PropertyRepository>();
  late Future<UserModel?>? userDataFuture;
  final _chatRepo = Get.find<ChatRepository>();
  final Rx<List<PropertyModel>> properties = Rx([]);

  Future<void> _refresh() async {
    await _userRepo.getUserDetails(_userRepo.currentUser.value!.email);
    await _userRepo.getProperties();
    final fetchedProperties =
    await _propertyController.getCurrentLoggedInAgentsProperties();

    properties.value = fetchedProperties;
  }

  @override
  void initState() {
    super.initState();
    userDataFuture = Future.value(_userRepo.currentUser.value);
  }

  Widget _verifiedIconWidget() {
    return const CircleAvatar(
      radius: 8, // Adjust as needed
      backgroundColor: Color(0xFFFFD700), // Adjust as needed
      child: Icon(
        Icons.check,
        color: Colors.black, // Adjust as needed
        size: 12, // Adjust as needed
        weight: 100,
      ),
    );
  }

  Widget _statItem(
      int number,
      String title,
      ) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "$number",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              fontFamily: "Roboto",
            ),
          ),
          Text(
            title,
            style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
                fontSize: 8.sp,
                fontFamily: "Roboto"),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  PreferredSizeWidget appBar(Rx<UserModel?> user) {
    return AppBar(
      title: Text(
        "${user.value!.firstName} ${user.value!.lastName}",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
          fontFamily: "Roboto",
        ),
      ),
      backgroundColor: Colors.black87,
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: IconTheme(
            data: IconThemeData(
              color: Colors.white,
              size: 12.sp,
            ),
            child: const FaIcon(FontAwesomeIcons.gear),
          ),
          onSelected: (String result) {
            if (result == "Edit Profile") {
              Get.to(() => const EditProfile());
            }
            if (result == "Logout") {
              _userRepo.signOut();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'Edit Profile',
              child: Text('Edit Profile'),
            ),
            const PopupMenuItem<String>(
              value: 'Logout',
              child: Text('Logout'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Rx<UserModel?> user = _userRepo.currentUser;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: appBar(user),
      body: FutureBuilder(
        future: userDataFuture,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              final userData = snapshot.data;
              if (userData != null) {
                print("${userData.firstName}");
                userDataFuture?.then((data) =>
                    print("Property IDs length: ${data?.propertyIds?.length}"));
                // Use userData safely here
                return Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w, vertical: 1.h
                  ),
                  height: 89.h,
                  color: Colors.grey.shade200,
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _appBar(user.value!),
                              SizedBox(height: 1.5.h,),
                              Text(
                                "Property Management",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 12.sp, fontWeight: FontWeight.w500),
                              ),
                              FutureBuilder(
                                future: _propertyController
                                    .getCurrentLoggedInAgentsProperties(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final properties =
                                    snapshot.data as List<PropertyModel>;
                                    final length = properties.length;

                                    return SizedBox(
                                      child: _body(size, length),
                                    );
                                  } else {
                                    return _shimmeringCard();
                                  }
                                },
                              ),
                              SizedBox(
                                height: 1.5.h,
                              ),
                              Text(
                                "Messages",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 12.sp, fontWeight: FontWeight.w500),
                              ),
                              messagesCard(),
                            ],
                          ),
                        ]),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return const Center(
                child: Text('No data available'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget messagesCard() {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Convert the single-subscription streams to broadcast streams
    Stream<QuerySnapshot> chatRoomsStream = _chatRepo.getChatRooms().asBroadcastStream();

    return SizedBox(
      width: 100.w,
      height: 31.h,
      child: Card(
        color: Colors.white,
        elevation: 0.2,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatRoomsStream,
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshotC) {
                  if (snapshotC.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshotC.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final hasChatRooms = snapshotC.data?.docs.length != null
                      ? snapshotC.data!.docs.length > 0
                      : false;

                  print("has chatrooms is: $hasChatRooms}");

                  if (hasChatRooms) {
                    return Column(
                      children: [

                        FutureBuilder<UserModel>(
                          future: _chatRepo.getOtherUser(
                              snapshotC.data!.docs.first['participants']
                                  .firstWhere((id) => id != currentUserId) as String
                          ),
                          builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                  ),
                                  title: Container(
                                    color: Colors.white,
                                    width: double.infinity,
                                  ),
                                  subtitle: Container(
                                    color: Colors.white,
                                    width: double.infinity,
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              print("Error in build user model: ${snapshot.error}");
                              return Text('Failed to load user details');
                            } else {
                              UserModel? userData = snapshot.data;
                              String? firstName = userData?.firstName;
                              String? lastName = userData?.lastName;
                              var userImageUrl = userData?.imageUrl;
                              var otherUserType = userData is AgentModel
                                  ? 'agent'
                                  : 'client';



                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var chatRoomDoc in snapshotC.data!.docs)
                                    ListTile(
                                      tileColor: Colors.transparent,
                                      leading: userImageUrl != null &&
                                          userImageUrl.isNotEmpty
                                          ? CircleAvatar(
                                        radius: 6.w,
                                        backgroundImage: NetworkImage(userImageUrl),
                                      )
                                          : ProfilePicture(
                                          name: "$firstName $lastName",
                                          radius: 6.w,
                                          fontsize: 14.sp),
                                      title: Text("$firstName $lastName" ?? 'Unknown User'),
                                      subtitle: Text(
                                          chatRoomDoc['lastMessage'] ?? '',
                                          overflow: TextOverflow.ellipsis),
                                      subtitleTextStyle: TextStyle(
                                          color: Colors.grey.shade700
                                      ),
                                      trailing: Text(DateFormat('hh:mm a')
                                          .format(chatRoomDoc['timestamp'].toDate())),
                                      leadingAndTrailingTextStyle: const TextStyle(
                                        color: Color(0xFF008080),
                                      ),
                                      onTap: () {
                                        Get.to(() => ChatPage(
                                          receiverUserId: chatRoomDoc['participants']
                                              .firstWhere((id) => id != currentUserId)
                                          as String,
                                          otherImageUrl: userImageUrl,
                                          otherFirstName: firstName,
                                          otherLastName: lastName,
                                          currentUserType: 'agent',
                                          // You need to provide the currentUserType here
                                          receiverUserType: otherUserType,
                                        ));
                                      },
                                    ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }
                  else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.envelopeOpen,
                            size: 50.sp,
                            color:
                            Colors.black38, // Adjust opacity or color as needed
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "No Messages Yet",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
            Divider(),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to a new screen where all messages are displayed
                  // Get.to(() => AllChatRoomsPage());
                },
                child: Text(
                  'View More',
                  style:
                  TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmeringCard() {
    return SizedBox(
      height: 12.h,
      width: 100.w,
      child: Card(
        elevation: 0.2,
        color: Colors.white,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
            ),
            title: Container(
              color: Colors.white,
              width: double.infinity,
              height: 10.0,
            ),
            subtitle: Container(
              color: Colors.white,
              width: double.infinity,
              height: 10.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            user.imageUrl != null && user.imageUrl!.isNotEmpty
                ? CircleAvatar(
              radius: 10.w,
              backgroundImage: NetworkImage(user.imageUrl!),
            )
                : ProfilePicture(
              name: user.firstName.isNotEmpty
                  ? "${user.firstName} ${user.lastName}"
                  : "",
              radius: 10.w,
              fontsize: 18.sp,
            ),
            SizedBox(width: 6.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.solidEnvelope,
                      size: 12.sp,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                          fontFamily: "Roboto"),
                    ),
                  ],
                ),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.phone,
                      size: 12.sp,
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      user.phoneNo,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 10.sp,
                          fontFamily: "Roboto"),
                    ),
                  ],
                ),
                SizedBox(
                  height: 1.h,
                ),
                // Row(
                //   children: [
                //     ClipRRect(
                //       borderRadius: BorderRadius.circular(100),
                //       child: BackdropFilter(
                //         filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                //         child: Container(
                //           width: 22.w,
                //           decoration: BoxDecoration(
                //             color: Colors.grey.shade500.withOpacity(0.5),
                //             borderRadius: BorderRadius.circular(100),
                //           ),
                //           child: Center(
                //             child: Text(
                //               "Verified Agent",
                //               style: TextStyle(
                //                   color: Colors.black,
                //                   fontSize: 8.sp,
                //                   fontWeight: FontWeight.w500,
                //                   fontFamily: "Roboto"), // Adjust as needed
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //     SizedBox(
                //       width: 1.25.h,
                //     ),
                //     _verifiedIconWidget(),
                //   ],
                // ),
              ],
            )
          ],
        ),
        SizedBox(
          height: 1.5.h,
        ),
        Text(
          "Agent Bio",
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          height: 14.h,
          width: 100.w,
          child: Card(
            elevation: 0.2,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Passionate Real Estate Agent with 10+ years of experience. "
                        "Specializing in residential properties. "
                        "Committed to finding your dream home. Contact me!",
                    style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 10.sp,
                        fontFamily: "Roboto"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(Size size, int? numOfListings) {
    return Dashboard(
      numOfListings: numOfListings ?? 0,
    );
  }
}
