import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/chat/message.dart';

import '../../services/userAuthService/firebase_auth_implementation/firebase_auth_services.dart';

class ChatService extends ChangeNotifier{
  final FirebaseAuthService _auth = FirebaseAuthService();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //SEND MESSAGE
Future<void> sendMessage(String receiverId, String message, String senderName) async{
  //get current user info
  final String currentUserId = _auth.getUserId();
  final String currentUserName = senderName;
  final Timestamp timestamp = Timestamp.now();
  //create a new message

  Message newMessage = Message(
      senderId: currentUserId,
      senderName: currentUserName,
      receiverId: receiverId,
      message: message,
      timeStamp: timestamp
  );

  //construct chatting room id
  List<String> id = [currentUserId, receiverId];
  id.sort();
  String chatRoomId = id.join("_");

  await _fireStore.collection('chat').doc(chatRoomId).collection('messages').add(newMessage.toMap());

  }

  //get messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
  List<String> id = [userId,otherUserId];
  id.sort();
  String chatRoomId = id.join("_");

  return _fireStore.collection("chat")
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: true).snapshots();
  }
}