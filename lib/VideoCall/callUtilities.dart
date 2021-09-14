import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:telegram_clone/VideoCall/pickupScreen.dart';
import 'callMethods.dart';
import 'call.dart';
import 'package:telegram_clone/chatPage.dart';
import 'callScreen.dart';

class CallUtils{
  User CurrentUser;
  String uid;
  Stream<DocumentSnapshot> documentSnapshots;


  FirebaseAuth auth = FirebaseAuth.instance;



  Future getCurrentUser()async{
    User user= await auth.currentUser;
    if(user!=null){
      CurrentUser = user;
      uid = CurrentUser.uid;
      print('the uid is $uid');
      Stream documentSnapshot =  FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
      documentSnapshots=documentSnapshot;
    }
  }
  final CallMethods callMethods = CallMethods();
  dial({
    final String receiverId,
  final String receiverAvatar,
  final String receiverName,
  final String senderId,
  final String senderPic,
  final String senderName,
    final String uid,
    context
  })async{

    Call call = Call(
      callerid: senderId,
      callerName: senderName,
      callerPic: senderPic,
      receiverid: receiverId,
      receiverName:receiverName,
      receiverPic: receiverAvatar,
      channelid: Random().nextInt(1000).toString()
    );
    bool CallMade = await callMethods.makeCall(call:call);
    call.hasDailed =true;

    if(CallMade){
      await Navigator.push(context, MaterialPageRoute(builder: (context)=>CallScreen(call:call)));


    }

}
}

// Call call = Call(
//     callerid: from.uid.toString(),
//     callerName: from.displayName.toString(),
//     callerPic: from.photoURL.toString(),
//     receiverid: to.uid.toString(),
//     receiverName: to.displayName.toString(),
//     receiverPic: to.photoURL.toString(),
//     channelid: Random().nextInt(1000).toString()
// );