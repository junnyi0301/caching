import 'dart:ui';

import 'package:caching/auth/auth_service.dart';
import 'package:caching/chat/services/chat_service.dart';
import 'package:caching/chat/views/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverName;
  final String receiverEmail;
  final String receiverID;

  ChatPage({super.key, required this.receiverEmail, required this.receiverID, required this.receiverName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //Controller
  final TextEditingController messageInputCtrl = TextEditingController();

  //Services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FocusNode focusNode = FocusNode();
  final ScrollController scrollCtrl = ScrollController();

  @override
  void initState() {
    focusNode.addListener((){
      if(focusNode.hasFocus){
        Future.delayed(const Duration(milliseconds: 100), () => scrollDown());
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () => scrollDown());

    super.initState();
  }

  @override
  void dispose() {
    messageInputCtrl.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void scrollDown(){
    scrollCtrl.animateTo(scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.fastOutSlowIn);
  }

  void sendMessage() async {
    if (messageInputCtrl.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverID, messageInputCtrl.text);

      scrollDown();
      messageInputCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName),
          backgroundColor: Color(0xFFB9D3FB),
      ),
      backgroundColor: Color(0xFFE7EEFD),
      body: Column(
        children: [
          SizedBox(height: 24,),
          //Display messages
          _buildMessageList(),

          //User input
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    controller: messageInputCtrl,
                    decoration: const InputDecoration(
                        hintText: "Message",
                        fillColor: Colors.black12,
                        filled: true),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  margin: EdgeInsets.only(left: 12),
                  child: IconButton(onPressed: sendMessage, icon: Icon(Icons.send), color: Colors.white,)
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _auth.currentUser!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(widget.receiverID, senderID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return Flexible(
            child: ListView(
              controller: scrollCtrl,
              children: snapshot.data!.docs
                  .map((doc) => _buildMessageItem(doc))
                  .toList(),
            ),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //Is current user
    bool isCurrentUser = data["senderID"] == _auth.currentUser!.uid;

    return ChatBubble(message: data["message"], isCurrentUser: isCurrentUser);
  }
}
