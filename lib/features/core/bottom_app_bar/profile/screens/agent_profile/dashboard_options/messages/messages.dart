import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/model/user_models/user_model.dart';
import 'package:property_match_258_v5/repository/chat_repository/chat_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/agent_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../../../model/user_models/agent_model.dart';
import '../../../../../../pages/chat_page.dart';

class Messages extends StatefulWidget {
  const Messages({super.key});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  final _firestore = FirebaseFirestore.instance;

  final _agentRepo = Get.find<AgentRepository>();
  final _chatRepo = Get.find<ChatRepository>();
  final _clientRepo = Get.find<UserRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: IconTheme(
            data: IconThemeData(
              size: 14.sp,
              color: Colors.white,
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Messages",
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
        color: Colors.grey.shade300,
        child: messagesCard(),
      ),
    );
  }

  Future<String> getOtherUserType(String otherUserId) async {
    // Check if the user ID exists in the 'agents' collection
    var agentDoc = await _firestore.collection('agents').doc(otherUserId).get();
    if (agentDoc.exists) {
      return 'agent';
    }

    // Check if the user ID exists in the 'clients' collection
    var clientDoc =
        await _firestore.collection('clients').doc(otherUserId).get();
    if (clientDoc.exists) {
      return 'client';
    }

    // If the user ID does not exist in either collection, return an empty string
    return '';
  }

  Widget messagesCard() {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return SizedBox(
      width: 100.w,
      height: 100.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
                    StreamBuilder<QuerySnapshot>(
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
                                var lastMessage =
                                    chatRoomDoc['lastMessage'] ?? '';
                                var timestamp =
                                    chatRoomDoc['timestamp'] as Timestamp;
                                var formattedTime = DateFormat('hh:mm a')
                                    .format(timestamp.toDate());
                                var agentName =
                                    chatRoomDoc['agentName'] ?? 'Unknown User';
                          
                                if (lastMessage.length > 30) {
                                  lastMessage =
                                      lastMessage.substring(0, 30) + '...';
                                }
                          
                                var userIds =
                                    (chatRoomDoc['participants'] as List)
                                        .map((item) => item as String)
                                        .toList();
                                var otherUserId = userIds
                                    .firstWhere((id) => id != currentUserId);
                          
                                return FutureBuilder<UserModel>(
                                  future: _chatRepo.getOtherUser(otherUserId),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<UserModel> snapshot) {
                                    if (snapshot.connectionState ==
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
                                    } else if (snapshot.hasError) {
                                      print(
                                          "Error in build user model: ${snapshot.error}");
                                      return Text('Failed to load user details');
                                    } else {
                                      var userData = snapshot.data;
                                      String? firstName = userData?.firstName;
                                      String? lastName = userData?.lastName;
                                      var userImageUrl = userData?.imageUrl;
                                      var otherUserType = userData is AgentModel
                                          ? 'agent'
                                          : 'client';
                          
                                      return Card(
                                        elevation: 0.2,
                                        color: Colors.white,
                                        child: ListTile(
                                          leading: userImageUrl != null &&
                                                  userImageUrl.isNotEmpty
                                              ? CircleAvatar(
                                                  backgroundImage:
                                                      NetworkImage(userImageUrl),
                                                )
                                              : ProfilePicture(
                                                  name: "$firstName $lastName",
                                                  radius: 3.w,
                                                  fontsize: 8.sp),
                                          title: Text("$firstName $lastName" ??
                                              'Unknown User'),
                                          subtitle: Text('$lastMessage',
                                              overflow: TextOverflow.ellipsis),
                                          trailing: Text(formattedTime),
                                          // Display the formatted time
                                                                  
                                          onTap: () {
                                            Get.to(() => ChatPage(
                                                  receiverUserId: otherUserId,
                                                  otherImageUrl: userImageUrl,
                                                  otherFirstName: firstName,
                                                  otherLastName: lastName,
                                                  currentUserType: 'agent',
                                                  // You need to provide the currentUserType here
                                                  receiverUserType: otherUserType,
                                                ));
                                          },
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                              separatorBuilder: (context, index) => Divider(),
                            ),
                          ],
                        );
                      },
                    ),
                  ]),
      ),
    );
  }
}
