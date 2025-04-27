import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  Message(
      {required this.senderID,
      required this.timestamp,
      required this.message,
      required this.receiverID,
      required this.senderEmail});

  //Convert to a map
  Map<String, dynamic> toMap(){
    return{
      "senderID" : senderID,
      "senderEmail" : senderEmail,
      "receiverID" : receiverID,
      "message" : message,
      "timestamp" : timestamp
    };
  }
}
