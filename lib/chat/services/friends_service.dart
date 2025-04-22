import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Add friend
  Future<void> addFriend(String friendID) async {
    await _firestore.collection("friendsList").doc(_auth.currentUser!.uid).collection("friends").add({"friendID" : friendID});
  }

  //Get friend
  Stream<List<Map<String, dynamic>>> getFriendStream() {
    return _firestore.collection("friendsList").doc(_auth.currentUser!.uid).collection("friends").snapshots().map((snapshot) {
      return snapshot.docs.map((doc){
        final user = doc.data();
        return user;
      }).toList();
    });
  }
}