class Profile {
  String photoUrl;
  String name;
  String uid;
  String gender;
  int age;
  String description;
  String phoneNumber;

  Profile({
    required this.photoUrl,
    required this.name,
    required this.uid,
    required this.gender,
    required this.age,
    required this.description,
    required this.phoneNumber,
  });

  factory Profile.fromMap(Map<String, dynamic> m) {
    return Profile(
      photoUrl:    m['photoUrl']    as String? ?? 'assets/images/blank_images.jpg',
      name:        m['name']        as String? ?? '',
      uid:         m['uid']         as String? ?? '',
      gender:      m['gender']      as String? ?? 'Not set',
      age:         (m['age']        as int?)   ?? 0,
      description: m['description'] as String? ?? 'Not set',
      phoneNumber:  m['phoneNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photoUrl':    photoUrl,
      'name':        name,
      'uid':         uid,
      'gender':      gender,
      'age':         age,
      'description': description,
      'phoneNumber':  phoneNumber,
    };
  }
}