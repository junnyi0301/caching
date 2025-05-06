class EditProfileData {
  String photoUrl;
  String name;
  int age;
  String gender;
  String description;
  String phoneNumber;

  EditProfileData({
    required this.photoUrl,
    required this.name,
    required this.gender,
    required this.age,
    required this.description,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'photoUrl': photoUrl,
      'name': name,
      'age': age,
      'gender': gender,
      'description': description,
      'phoneNumber': phoneNumber,
    };
  }
}

