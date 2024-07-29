import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  late final String senderId;
  late final String receiverId;
  late final String message;
  late final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  toJson() {
    return {
      'SenderId': senderId,
      'ReceiverId': receiverId,
      'Message': message,
      'TimeStamp': timestamp,
    };
  }

  factory Message.fromSnapshot(DocumentSnapshot<Object?> document) {
    final data = document.data() as Map<String, dynamic>;
    return Message(
      senderId: data['SenderId'] ?? '',
      receiverId: data['ReceiverId'] ?? '',
      message: data['Message'] ?? '',
      timestamp: data['TimeStamp'] ?? 0,
    );
  }

}