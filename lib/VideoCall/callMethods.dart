import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'call.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallMethods{

  Stream<DocumentSnapshot> callStream({String uid}){
    FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<bool> makeCall({Call call})async{
    try{
      call.hasDailed = true;
      Map<String,dynamic> hasDialedMap = call.toMap(call);
      call.hasDailed = false;
      Map<String,dynamic> hasNotDialedmap = call.toMap(call);

      await FirebaseFirestore.instance.collection('users').doc(call.callerid).set(hasDialedMap);
      await FirebaseFirestore.instance.collection('users').doc(call.receiverid).set(hasNotDialedmap);
      return true;

    }catch(e){
      print(e);
      return false;
    }
  }

  Future<bool> endCall({Call call})async{
    try{
      await FirebaseFirestore.instance.collection('users').doc(call.callerid).delete();
      await FirebaseFirestore.instance.collection('users').doc(call.receiverid).delete();
      return true;
    }catch(e){
      print(e);
      return false;
    }

  }
}