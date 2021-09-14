import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Users{
  final String id;
  final String nickname;
  final String photoUrl;
  final String createdAt;

  Users({this.id,this.createdAt,this.nickname,this.photoUrl});

  factory Users.fromDocument(DocumentSnapshot document){
    return Users(
        id: document['id'],
      photoUrl: document['photoUrl'],
      nickname: document['nickname'],
      createdAt: document['createdAt'],
    );

  }


}


