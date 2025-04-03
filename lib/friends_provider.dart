import 'package:flutter/material.dart';
import 'user.dart';

class FriendsProvider extends ChangeNotifier{
  final List<User> userList = [];

  void add(User user){
    userList.add(user);
    notifyListeners();
  }

  void remove(User user){
    userList.remove(user);
    notifyListeners();
  }
}