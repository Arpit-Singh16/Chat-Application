import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class profileprovider extends ChangeNotifier{

  String? username;
  String? phone;
  String? tagline;
  Future<void> loadProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      username = data['username'] ?? '';
      phone = data['phone'] ?? '';
      tagline = data['tagline'] ?? '';
      notifyListeners();
    }
  }
  Future<void> updateProfile(String name , String phone, String tag) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'username': name,
        'phone': phone,
        'tagline':tag
        }
      );
  notifyListeners();
  }


}