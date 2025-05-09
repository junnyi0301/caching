import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caching/users/model/profile.dart';
import 'package:caching/users/model/edit_profile.dart';


class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid => _auth.currentUser!.uid;

  /// Stream of current user’s Profile
  Stream<Profile?> getProfileStream() {
    return _firestore
        .collection('Users')
        .doc(_uid)
        .snapshots()
        .map((snap) {
      final m = snap.data();
      return m == null ? null : Profile.fromMap(m);
    });
  }

  /// One‑time fetch
  Future<Profile?> getUserOnce() async {
    final snap = await _firestore.collection('Users').doc(_uid).get();
    final m = snap.data();
    return m == null ? null : Profile.fromMap(m);
  }

  /// Update only the editable profile fields
  Future<void> updateUserProfile(EditProfileData data) async {
    final doc = _firestore.collection('Users').doc(_uid);

    final map = <String, dynamic>{
      'name': data.name,
      'age': data.age,
      'gender': data.gender,
      'description': data.description,
      'phone': data.phone,
      'photoUrl': data.photoUrl,
    };

    await doc.set(map, SetOptions(merge: true));
  }
}