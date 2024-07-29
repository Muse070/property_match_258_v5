import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:property_match_258_v5/repository/chat_repository/chat_repository.dart';
import 'package:property_match_258_v5/widgets/widget_bubble.dart';
import 'package:sizer/sizer.dart';

import '../../../model/message_model/message_model.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserId;
  final String currentUserType;
  final String? receiverUserType;
  final String? otherImageUrl;
  final String? otherFirstName;
  final String? otherLastName;

  const ChatPage({
    super.key,
    required this.receiverUserId,
    required this.otherImageUrl,
    required this.otherFirstName,
    required this.otherLastName,
    required this.currentUserType,
    required this.receiverUserType,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatRepository _chatRepo = ChatRepository();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    try {
      if (_messageController.text.isNotEmpty) {
        await _chatRepo.sendMessage(
          widget.receiverUserId,
          _messageController.text,
          widget.currentUserType,
          widget.receiverUserId,
        );
        _messageController.clear();
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
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
          "${widget.otherFirstName} ${widget.otherLastName}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: "Roboto",
            fontSize: 14.sp,
          ),
        ),
        actions: [
          widget.otherImageUrl != null && widget.otherImageUrl!.isNotEmpty
              ? GestureDetector(
            onTap: () {
              if (widget.otherImageUrl != null &&
                  widget.otherImageUrl!.isNotEmpty) {
                showDialog(
                  context: context,
                  builder: (context) =>
                      Dialog(
                        child: _buildUserProfileModal(),
                      ),
                );
              }
            },
            child: CircleAvatar(
              radius: 4.w,
              backgroundImage: NetworkImage(widget.otherImageUrl ?? ''),
              // provide a default value
              backgroundColor: Colors.blue,
            ),
          )
              : ProfilePicture(
              name: "${widget.otherFirstName} ${widget.otherLastName}",
              radius: 4.w,
              fontsize: 8.sp),
          SizedBox(
            width: 4.w,
          )
        ],
      ),
      body: Container(
        color: Colors.grey.shade300,
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileModal() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for bottom sheets
        children: [
          // Enlarged Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            // Optional rounded corners
            child: Image.network(
              widget.otherImageUrl!,
              width: 200, // Adjust size as needed
              height: 200,
            ),
          ),
          SizedBox(height: 16), // Spacing
          // User Information
          Text(
            "${widget.otherFirstName} ${widget.otherLastName}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          // ... (Add more user info like bio, email, etc.)
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    try {
      print(_firebaseAuth.currentUser!.uid);
      return StreamBuilder(
        stream: _chatRepo.getMessages(
            _firebaseAuth.currentUser!.uid, widget.receiverUserId),
        builder: (context, snapshot) {
          print("Current user id is ${_firebaseAuth.currentUser!.uid}");

          print("Receiver user id is ${widget.receiverUserId}");

          List<String> ids = [
            widget.receiverUserId,
            _firebaseAuth.currentUser!.uid
          ];
          ids.sort();
          String chatRoomId = ids.join("_");

          print("Chatroom id is: ${chatRoomId}");
          if (snapshot.hasData) {
            print("Print snapshot: ${snapshot.data!.docs
                .map((doc) => Message.fromSnapshot(doc))
                .toList()}");

            var messages = snapshot.data!.docs
                .map((doc) => Message.fromSnapshot(doc))
                .toList();


            // Print out the messages
            for (var message in messages) {
              print('Message: ${message.message}');
            }

            // Group messages by date
            var messagesByDate = <String, List<Message>>{};
            for (var message in messages) {
              var date = DateFormat.yMMMd().format(message.timestamp.toDate());
              if (messagesByDate[date] == null) {
                messagesByDate[date] = [];
              }
              messagesByDate[date]!.add(message);
            }

            return ListView(
              children: messagesByDate.entries.map((entry) {
                var date = entry.key;
                var messagesForDate = entry.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Card(
                      color: Colors.white, // exceptional color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // radius
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          date,
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ...messagesForDate
                        .map((message) => _buildMessageItem(message)),
                  ],
                );
              }).toList(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      );
    } catch (e) {
      print('Error building message list: $e');
      return Text('Error building message list: $e');
    }
  }

  Widget _buildMessageItem(Message message) {
    try {
      bool isOwnMessage = (message.senderId == _firebaseAuth.currentUser!.uid);
      DateTime messageTime = message.timestamp.toDate();
      String formattedTime = DateFormat.jm().format(messageTime);

      return Container(
        alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: isOwnMessage
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              ChatBubble(message: message.message, isOwnMessage: isOwnMessage),
              Text(formattedTime),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error building message item: $e');
      return Text('Error building message item: $e');
    }
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter Message',
                filled: true,
                fillColor: Colors.grey[200], // grayish color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0), // radius
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send, // send icon
              size: 40,
              color: Colors.blue, // color of the icon
            ),
          )
        ],
      ),
    );
  }
}
