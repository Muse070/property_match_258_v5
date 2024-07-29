import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/dashboard_options/messages/messages.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/client_profile/favorite_agents.dart';
import 'package:property_match_258_v5/features/core/pages/chat_page.dart';
import 'package:property_match_258_v5/repository/user_repository/agent_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../model/user_models/agent_model.dart';
import '../../../../../../model/user_models/client_model.dart';
import '../../../../../../model/user_models/user_model.dart';
import '../../../../../../repository/chat_repository/chat_repository.dart';
import '../../../../../../repository/properties_repository/property_repository.dart';
import '../../../../../../repository/user_repository/user_repository.dart';
import '../edit_profile/edit_profile.dart';

class ClientProfilePage extends StatefulWidget {
  const ClientProfilePage({super.key});

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  final _userRepo = Get.find<UserRepository>();
  final _agentRepo = Get.find<AgentRepository>();
  final _chatRepo = Get.find<ChatRepository>();
  final _propertyController = Get.find<PropertyRepository>();


  late Future<ClientModel?>? userDataFuture;

  @override
  void initState() {
    super.initState();
    userDataFuture = Future.value(_userRepo.getClient(_userRepo.currentUser.value!.id));
  }

  Future<void> _refresh() async {
    await _userRepo.getUserDetails(_userRepo.currentUser.value!.email);
    await _userRepo.getProperties();
  }

  @override
  Widget build(BuildContext context) {
    Rx<UserModel?> user = _userRepo.currentUser;

    return Scaffold(
      appBar: appBar(user),
      body: FutureBuilder(
        future: userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              ClientModel? userData = snapshot.data;
              return RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 100.w,
                      height: 83.h,
                      color: Colors.grey.shade200,
                      alignment: Alignment.centerLeft,
                      padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _appBar(userData!),
                          SizedBox(
                            height: 1.5.h,
                          ),
                          Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Manage Agents",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                favoriteAgentsCard(),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                Text(
                                  "Messages",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                messagesCard()
                              ])
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            } else {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget favoriteAgentsCard() {
    return SizedBox(
      width: 100.w,
      height: 12.h,
      child: GestureDetector(
        onTap: ()=> Get.to(() => const FavoriteAgents()),
        child: Card(
          color: Colors.white,
          elevation: 0.2,
          child: Center(
            child: ListTile(
              leading: CircleAvatar(
                radius: 6.w,
                backgroundColor: Colors.black87,
                child: FaIcon(
                  FontAwesomeIcons.userGroup,
                  color: Color(0xFF80CBC4),
                  size: 14.sp,
                ),
              ),
              title: Text(
                "Favorite Agents",
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
              ),
              trailing: TextButton(
                onPressed: () {
                  Get.to(() => const FavoriteAgents());
                },
                child: const Text(
                  "View All",
                  style: TextStyle(
                    color: Color(0xFF008080),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget messagesCard() {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return SizedBox(
      width: 100.w,
      height: 31.h,
      child: Card(
        color: Colors.white,
        elevation: 0.2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _chatRepo.getChatRooms(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        // to give the ListView a height
                        itemCount: min(3, snapshot.data!.docs.length),
                        itemBuilder: (context, index) {
                          var chatRoomDoc = snapshot.data!.docs[index];
                          var chatRoomId = chatRoomDoc.id;
                          var lastMessage = chatRoomDoc['lastMessage'] ?? '';
                          var timestamp = chatRoomDoc['timestamp'] as Timestamp;
                          var formattedTime =
                          DateFormat('hh:mm a').format(timestamp.toDate());
                          var agentName =
                              chatRoomDoc['agentName'] ?? 'Unknown User';

                          if (lastMessage.length > 30) {
                            lastMessage = lastMessage.substring(0, 30) + '...';
                          }

                          var userIds = (chatRoomDoc['participants'] as List)
                              .map((item) => item as String)
                              .toList();
                          var otherUserId =
                          userIds.firstWhere((id) => id != currentUserId);

                          return FutureBuilder<AgentModel>(
                            future: _agentRepo.getAgent(otherUserId),
                            builder: (BuildContext context,
                                AsyncSnapshot<AgentModel> agentSnapshot) {
                              if (agentSnapshot.connectionState ==
                                  ConnectionState.waiting) {
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
                                      height: 10.0,
                                    ),
                                    subtitle: Container(
                                      color: Colors.white,
                                      width: double.infinity,
                                      height: 10.0,
                                    ),
                                  ),
                                );
                              } else if (agentSnapshot.hasError) {
                                return Text('Failed to load agent details');
                              } else {
                                AgentModel agent = agentSnapshot.data!;
                                String? imageUrl = agent.imageUrl;
                                return ListTile(
                                  leading: imageUrl != null &&
                                      imageUrl.isNotEmpty
                                      ? CircleAvatar(
                                    radius: 6.w,
                                    backgroundImage:
                                    NetworkImage(imageUrl!),
                                    // assuming 'imageUrl' is the field name
                                    backgroundColor: Colors.blue,
                                  )
                                      : ProfilePicture(
                                      name:
                                      "${agent.firstName} ${agent.lastName}",
                                      radius: 6.w,
                                      fontsize: 14.sp),
                                  title: Text(
                                    agentName,
                                    style:
                                    TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                  subtitle: Text('$lastMessage',
                                      overflow: TextOverflow.ellipsis),
                                  subtitleTextStyle:
                                  TextStyle(color: Colors.grey.shade700),
                                  trailing: Text(formattedTime),
                                  leadingAndTrailingTextStyle: const TextStyle(
                                    color: Color(0xFF008080),
                                  ),
                                  onTap: () {
                                    Get.to(() => ChatPage(
                                      receiverUserId: otherUserId,
                                      otherImageUrl: imageUrl!,
                                      otherFirstName: agent.firstName,
                                      otherLastName: agent.lastName,
                                      currentUserType: 'client',
                                      receiverUserType: agent.userType,
                                    ));
                                  },
                                );
                              }
                            },
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider();
                        },
                      )
                      // if (snapshot.data!.docs.length >
                      //     3) // If there are more than 5 items...
                      //   TextButton(
                      //     onPressed: () {
                      //       // Navigate to a new screen where all messages are displayed
                      //     },
                      //     child: const Text('View More'),
                      //   ),
                    ],
                  );
                },
              ),
            ),
            Divider(),
            Center(
              child: TextButton(
                onPressed: () {
                  Get.to(() => const Messages());
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

  Widget _appBar(ClientModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            user.imageUrl != null && user.imageUrl!.isNotEmpty
                ? CircleAvatar(
              radius: 10.w,
              backgroundImage: NetworkImage(user.imageUrl!),
            )
                : ProfilePicture(
                name: "${user.firstName} ${user.lastName}",
                radius: 10.w,
                fontsize: 18.sp),
            SizedBox(
              width: 5.w,
            ),
            Column(
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
              ],
            )
          ],
        ),
        SizedBox(
          height: 1.5.h,
        ),
        Text(
          "Preferences",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.start,
        ),
        SizedBox(
          height: 14.h,
          width: 100.w,
          child: Card(
            elevation: 0.2,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(1.h),
              child: Container(
                width: 100.w,
                height: 100.h,
                padding: EdgeInsets.all(1.w),
                child: Text(
                  _userRepo.clientModel.value!.preferences!,
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                      fontSize: 10.sp,
                      fontFamily: "Roboto"),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget appBar(Rx<UserModel?> user) {
    return AppBar(
      title: Text(
        "${user.value!.firstName} ${user.value!.lastName}",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontFamily: "Roboto",
          fontSize: 14.sp,
        ),
      ),
      backgroundColor: Colors.black87,
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.settings,
            color: Colors.white,
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
}
