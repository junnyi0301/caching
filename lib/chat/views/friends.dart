import 'package:caching/auth/auth_service.dart';
import 'package:caching/chat/views/add_friend_tile.dart';
import 'package:caching/chat/services/chat_service.dart';
import 'package:caching/chat/services/friends_service.dart';
import 'package:caching/chat/views/friend_request_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'user_tile.dart';
import '../../utilities/design.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final design = Design();

  String email = "";
  List<String> myFriends = [];
  bool isLoadingFriends = true;

  //Controller
  final TextEditingController searchBarCtrl = TextEditingController();

  void logout() {
    _authService.signOut();
  }

  @override
  void initState() {
    super.initState();
    loadFriends();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFB9D3FB),
          title: Text("Friends", style: design.titleText),
        ),
        backgroundColor: Color(0xFFE7EEFD),
        body: Column(children: [
          TabBar(tabs: [
            Tab(
              text: "Friends",
            ),
            Tab(
              text: "Add Friends",
            )
          ]),
          Expanded(
            child: TabBarView(children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "Friends",
                      style: design.subtitleText,
                    ),
                    const SizedBox(height: 24),
                    //Friend request
                    Flexible(child: _buildUserList()),
                    const SizedBox(
                      height: 24,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 24,
                    ),
                    Text(
                      "Friend Requests",
                      style: design.subtitleText,
                    ),
                    const SizedBox(height: 8),
                    //Friends
                    Flexible(child: _buildRequestList())
                  ],
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchBarCtrl,
                            decoration: const InputDecoration(
                                hintText: "Enter friends email"),
                          ),
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.blue, shape: BoxShape.circle),
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    loadFriends();
                                    email = searchBarCtrl.text;
                                  });
                                },
                                icon: Icon(Icons.search)))
                      ],
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Expanded(child: _buildAddFriendList())
                  ],
                ),
              )
            ]),
          ),
          Container(
              margin: EdgeInsets.symmetric(vertical: 24),
              child: ElevatedButton(onPressed: logout, child: Text("Logout")))
        ]),
      ),
    );
  }

  Future<void> loadFriends() async {
    myFriends = await _friendService.getFriendsUIDs();
  }

  Widget _buildAddFriendList() {
    if (email.isNotEmpty) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .where("email", isEqualTo: email.toLowerCase())
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }

            if (snapshot.data!.docs.isEmpty ||
                email == _auth.currentUser!.email) {
              return Text("No result");
            }
            
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data!.docs[index].data();
                  bool isAlreadyFriends = myFriends.contains(data["uid"]);
                  return AddFriendTile(isFriend: isAlreadyFriends, name: data["name"], onTap: () => addFriend(data["uid"]));
                });
          });
    }
    return Container();
  }

  void addFriend(String uid) async{
    await _friendService.addFriend(uid);
    setState(() {

    });
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: _friendService.getFriendStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No friends found"));
          }

          return ListView(
            children: snapshot.data!
                .map<Widget>(
                    (userData) => _buildUserListItem(userData, context))
                .toList(),
          );
        });
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      unfriend: () => unfriend(context, userData["uid"]),
      text: userData["email"],
      name: userData["name"],
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                      receiverEmail: userData["email"],
                      receiverName: userData["name"],
                      receiverID: userData["uid"],
                    )));
      },
    );
  }

  Widget _buildRequestList() {
    return StreamBuilder(
        stream: _friendService.getFriendRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No friend request found"));
          }

          return ListView(
            children: snapshot.data!
                .map<Widget>(
                    (userData) => _buildRequestListItem(userData, context))
                .toList(),
          );
        });
  }

  Widget _buildRequestListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return FriendRequestTile(name: userData["name"] ,text: userData["email"], accept: () => accept(userData["uid"]), decline: () => decline(userData["uid"]));
  }

  void accept(String friendID) async {
    await _friendService.acceptFriend(friendID);
  }

  void decline(String friendID) async {
    await _friendService.unFriend(friendID);
  }

  Future<void> unfriend(BuildContext context, String friendID) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unfriend'),
        content: Text('Are you sure you want to unfriend this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm
            child: Text('Unfriend'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // User pressed Unfriend
      await _friendService.unFriend(friendID);
    }
  }
}
