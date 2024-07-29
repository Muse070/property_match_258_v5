import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/model/message_model/message_model.dart';
import 'package:property_match_258_v5/repository/user_repository/agent_repository.dart';
import 'package:property_match_258_v5/repository/user_repository/user_repository.dart';

import '../../model/user_models/agent_model.dart';
import '../../model/user_models/client_model.dart';
import '../../model/user_models/user_model.dart';

class ChatRepository extends GetxController {
  static ChatRepository get instance => Get.find();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _agentRepo = Get.find<AgentRepository>();
  final _clientRepo = Get.find<UserRepository>();

  StreamController<UserModel> userController = StreamController<UserModel>();

  final Rx<UserModel> user = Rx<UserModel>(UserModel(
    email: '',
    userType: '',
    address: '',
    city: '',
    country: '',
    firstName: '',
    id: '',
    password: '',
    phoneNo: '',
    propertyIds: [],
    lastName: '',
  )); // Add this line

  Future<void> sendMessage(String receiverId, String message, String currentUserType, String? receiverUserType) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderId: currentUserId,
        receiverId: receiverId,
        message: message,
        timestamp: timestamp
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Fetch the user's details
    UserModel userModel = await getOtherUser(receiverId);


    // Add the message to the 'messages' sub-collection
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toJson());

    // Update the last message, timestamp, and user's details in the chat room document
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .set({
      'lastMessage': message,
      'timestamp': timestamp,
      'userName': "${userModel.firstName} ${userModel.lastName}",
      'participants': ids,
      'senderType': currentUserType,
      'receiverType': receiverUserType,
    }, SetOptions(merge: true));
  }


  Future<UserModel> getOtherUser(String otherUserId) async {
    Completer<UserModel> completer = Completer();

    // Check if the user ID exists in the 'agents' collection
    _firestore.collection('agents').doc(otherUserId).snapshots().listen((agentDoc) {
      try {
        if (agentDoc.exists) {
          UserModel userModel = AgentModel.fromSnapshot(agentDoc);
          print("123 agent"); // Print the UserModel
          completer.complete(userModel);
        } else {
          // Check if the user ID exists in the 'clients' collection
          _firestore.collection('clients').doc(otherUserId).snapshots().listen((clientDoc) {
            try {
              if (clientDoc.exists) {
                UserModel userModel = ClientModel.fromSnapshot(clientDoc);
                print("123 Client"); // Print the UserModel
                completer.complete(userModel);
              } else {
                // If the user ID does not exist in either collection, throw an error
                completer.completeError(Exception('User not found'));
              }
            } catch (e) {
              print('Error occurred while checking client collection: $e');
              completer.completeError(e);
            }
          });
        }
      } catch (e) {
        print('Error occurred while checking agent collection: $e');
        completer.completeError(e);
      }
    });

    return completer.future;
  }


  // void listenToOtherUser(String otherUserId) {
  //   getOtherUser(otherUserId).listen((UserModel userModel) {
  //     user.value = userModel;
  //   });
  // }


  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    try {
      final result = _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('TimeStamp', descending: false)
          .snapshots()
          .handleError((error) {
        print("An error occurred: $error");
      });

      print("Result messages are: $result");

      return result;
    } catch (e) {
      print("An error occurred: $e");
      return const Stream.empty();
    }
  }

  Stream<QuerySnapshot> getChatRooms() {
    final String currentUserId = _firebaseAuth.currentUser!.uid;

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .snapshots();
  }
}
