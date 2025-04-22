import 'package:caching/auth/auth_service.dart';
import 'package:caching/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'user_tile.dart';
import '../../utilities/design.dart';

final design = Design();

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void logout() {
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Friends", style: design.titleText),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(child: _buildUserList()),
            ElevatedButton(onPressed: logout, child: Text("Logout"))
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
        stream: _chatService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          return ListView(
            children: snapshot.data!.map<Widget>((userData) => _buildUserListItem(userData, context)).toList(),
          );
        });
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      text: userData["email"],
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatPage(
                      receiverEmail: userData["email"],receiverID: userData["uid"],
                    )));
      },
    );
  }
}
