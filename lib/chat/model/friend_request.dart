class FriendRequest{
  final String status;
  final String name;
  final String uid;
  final String email;

  FriendRequest({required this.status, required this.name, required this.email, required this.uid});

  Map<String, dynamic> toMap(){
    return {
      "uid" : uid,
      "name" : name,
      "email" : email,
      "status" : status
    };
  }
}