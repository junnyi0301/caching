import 'package:caching/chat/model/friend_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Add friend
  Future<void> addFriend(String friendID) async {

    String currentUserID = _auth.currentUser!.uid;
    var currentUserSnapshot = await _firestore.collection("Users").doc(currentUserID).get();
    var friendSnapshot = await _firestore.collection("Users").doc(friendID).get();

    var currentUser = currentUserSnapshot.data() as Map<String, dynamic>;
    var friend = friendSnapshot.data() as Map<String, dynamic>;

    FriendRequest sendRequest = FriendRequest(status: "sent", name: friend["name"], email: friend["email"], uid: friend["uid"]);
    FriendRequest pendingRequest = FriendRequest(status: "pending", name: currentUser["name"], email: currentUser["email"], uid: currentUser["uid"]);

    await _firestore.collection("friendsList").doc(currentUserID).collection("friends").doc(friendID).set(sendRequest.toMap());
    await _firestore.collection("friendsList").doc(friendID).collection("friends").doc(currentUserID).set(pendingRequest.toMap());
  }

  //Accept friend
  Future<void> acceptFriend(String friendID) async {

    String currentUserID = _auth.currentUser!.uid;
    var currentUserSnapshot = await _firestore.collection("Users").doc(currentUserID).get();
    var friendSnapshot = await _firestore.collection("Users").doc(friendID).get();

    var currentUser = currentUserSnapshot.data() as Map<String, dynamic>;
    var friend = friendSnapshot.data() as Map<String, dynamic>;

    FriendRequest sendRequest = FriendRequest(status: "accepted", name: friend["name"], email: friend["email"], uid: friend["uid"]);
    FriendRequest pendingRequest = FriendRequest(status: "accepted", name: currentUser["name"], email: currentUser["email"], uid: currentUser["uid"]);

    await _firestore.collection("friendsList").doc(currentUserID).collection("friends").doc(friendID).set(sendRequest.toMap());
    await _firestore.collection("friendsList").doc(friendID).collection("friends").doc(currentUserID).set(pendingRequest.toMap());
  }

  //Unfriend
  Future<void> unFriend(String friendID) async {
    String currentUserID = _auth.currentUser!.uid;
    String receiverID = friendID;

    await _firestore.collection("friendsList").doc(currentUserID).collection("friends").doc(receiverID).delete();
    await _firestore.collection("friendsList").doc(receiverID).collection("friends").doc(currentUserID).delete();
  }

  //Get friend requests
  Stream<List<Map<String, dynamic>>> getFriendRequests(){
    return _firestore.collection("friendsList").doc(_auth.currentUser!.uid).collection("friends").where("status", isEqualTo: "pending").snapshots().map((snapshot){
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  //Get friends
  Stream<List<Map<String, dynamic>>> getFriendStream(){
    return _firestore.collection("friendsList").doc(_auth.currentUser!.uid).collection("friends").where("status", isEqualTo: "accepted").snapshots().map((snapshot){
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  //Search friend
  Stream<List<Map<String, dynamic>>> searchFriend(String email){
    return _firestore.collection("Users").snapshots().map((snapshot){
      return snapshot.docs.where((doc) => doc.data()["email"] == email).map((doc) => doc.data()).toList();
    });
  }

  Future<List<String>> getFriendsUIDs() async {
    final snapshot = await _firestore
        .collection("friendsList")
        .doc(_auth.currentUser!.uid)
        .collection("friends")
        .get();

    List<String> friendUIDs = snapshot.docs.map((doc) => doc['uid'] as String)
        .toList();

    return friendUIDs;
  }
}