import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlapd/screens/acceptedDeliveryDetails.dart';
import 'package:overlapd/screens/chat/chat_service.dart';
import 'package:overlapd/screens/requestedDeliveryStatus.dart';

import '../../user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import '../../utilities/widgets.dart';

class Chat extends StatefulWidget {
  final String receiverUserId;
  final String receiverUserName;
  final bool whatUser;
  const Chat({super.key, required this.whatUser, required this.receiverUserId, required this.receiverUserName});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();
  String? _lastSenderId;



  void sendMessage() async{
    if(_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.receiverUserId, _messageController.text, widget.receiverUserName);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                // Navigate to the home page with a fade transition
                Navigator.pushReplacement(
                  context,
                  pageAnimationlr(widget.whatUser
                      ? RequestedDeliveryStatus(placedByUserName: widget.receiverUserName, acceptedByUserId: widget.receiverUserId,)
                      : AcceptedDeliveryDetails(acceptedByUserName: widget.receiverUserName, placedByUserId: widget.receiverUserId) ),
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Chat',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: _buildMessageList()
          ),
          _buildMessageInput()
        ],
      ),
    );
  }

  Widget _buildMessageInput(){
    return Row(
      children: [
        Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter Message'
              ),
            )
        ),
        IconButton(onPressed: sendMessage, icon: const Icon(Icons.send_rounded))
      ],
    );
  }


  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = data['senderId'] == _UID ? Alignment.centerRight : Alignment.centerLeft;
    bool sameSender = _lastSenderId == data['senderId'];

    _lastSenderId = data['senderId'];
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: data['senderId'] == _UID ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: data['senderId'] == _UID ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!sameSender) Text(data['senderName']),
          chatBubble(data['message']),
        ],
      ),
    );

  }

  Widget _buildMessageList(){
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverUserId, _auth.getUserId()),
        builder: (context, snapshot){
    if (snapshot.connectionState == ConnectionState.waiting) {
    // If the data is still loading, return a loading indicator
    return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
    // If there's an error, display an error message
    return Text('Error: ${snapshot.error}');
    } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
    // If there is no data or the data is empty, display a message
    return const Text('No messages');
    } else {
      return ListView(
        children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
      );
    }
        }
    );
  }

  Widget chatBubble(String message){
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        alignment: Alignment.centerRight,
        width: MediaQuery.of(context).size.width/2,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFF21D19F)
        ),
        child: Text(
          message,
          maxLines: 10,
          overflow: TextOverflow.visible,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white
          ),
        ),
      ),
    );
  }

}
