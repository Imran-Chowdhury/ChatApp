import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier{
  User _user;
  User get getUser => _user;
  User CurrentUser;
  String uid;

  void refreshUser()async{
    User user =await getUserDetails();
    _user= user;
    notifyListeners();
  }

  FirebaseAuth auth = FirebaseAuth.instance;

  Future getUserDetails()async {
    User user = await auth.currentUser;
    if (user != null) {
      CurrentUser = user;
      uid = CurrentUser.uid;
      Future<DocumentSnapshot> documentSnapshot = FirebaseFirestore.instance.collection('users').doc(uid).get();

    }
  }


}