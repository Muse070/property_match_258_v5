import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isOwnMessage;

  const ChatBubble({Key? key, required this.message, required this.isOwnMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
      decoration: BoxDecoration(
        color: isOwnMessage ? Color(0xFF008080) : Color(0xFF80CBC4), // Teal for own messages, Light Teal for others
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isOwnMessage ? 12.0 : 0),
          topRight: Radius.circular(isOwnMessage ? 0 : 12.0),
          bottomLeft: Radius.circular(12.0),
          bottomRight: Radius.circular(12.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white70, // white70 color for the text
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
