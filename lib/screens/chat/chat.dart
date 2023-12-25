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
  final String? orderID;
  final String? deliveryAddress;
  final List? itemList;
  final bool whatUser;
  const Chat({super.key, required this.whatUser, required this.receiverUserId, required this.receiverUserName, this.orderID, this.deliveryAddress, this.itemList});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuthService _auth = FirebaseAuthService();
  late final String _UID = _auth.getUserId();

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
                Navigator.pop(
                  context,
                  pageAnimationlr(widget.whatUser
                      ? RequestedDeliveryStatus(placedByUserName: widget.receiverUserName, acceptedByUserId: widget.receiverUserId,)
                      : AcceptedDeliveryDetails(acceptedByUserName: widget.receiverUserName,
                    placedByUserId: widget.receiverUserId,
                    orderID: widget.orderID,
                    deliveryAddress: widget.deliveryAddress,
                    itemList: widget.itemList,
                    )
                  ),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
                child: _buildMessageList()
            ),
            _buildMessageInput()
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
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
      ),
    );
  }


  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isSender = data['senderId'] == _UID;
    var alignment = isSender ? Alignment.centerRight : Alignment.centerLeft;
    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          chatBubble(data['message'], isSender),

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
        reverse: true,
        children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
      );
    }
        }
    );
  }

  Widget chatBubble(String message, bool isSender){
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.none,

          child: Container(
            padding: isSender ? const EdgeInsets.only(top: 8, right: 8, left: 20, bottom: 8) : const EdgeInsets.only(top: 8, left: 8, right: 20, bottom: 8),
            decoration: BoxDecoration(
                borderRadius: isSender ? const BorderRadius.only(
                    topRight: Radius.circular(0),
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12))
                    : const BorderRadius.only(
                    topRight: Radius.circular(12),
                    topLeft: Radius.circular(0),
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12)),
                color: isSender ? const Color(0xFF21D19F) : const Color(0xFF21D19F).withOpacity(0.7)
            ),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 2
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
        ),
      ),
    );
  }

}
