import 'package:flutter/material.dart';

class Call{
  String callerid;
  String callerName;
  String callerPic;
  String receiverid;
  String receiverName;
  String receiverPic;
  String channelid;
  bool hasDailed;


  Call({
    this.callerName,
    this.callerid,
    this.callerPic,
    this.receiverName,
    this.receiverid,
    this.receiverPic,
    this.channelid,
    this.hasDailed,
});

  //to map

 Map<String,dynamic> toMap(Call call){
   Map<String,dynamic> callMap = Map();
   callMap['caller_name'] = call.callerName;
   callMap['caller_id']  = call.callerid;
   callMap['caller_pic'] = call.callerPic;
   callMap['receiver_name'] = call.receiverName;
   callMap['receiver_id'] = call.receiverid;
   callMap['receiver_pic'] = call.receiverPic;
   callMap['channel_id'] = call.channelid;
   callMap['has-dialed'] =call.hasDailed;
   return callMap;
 }

 Call.fromMap(Map callMap){
   this.callerName =callMap['caller_name'];
   this.callerid = callMap['caller_id'];
   this.callerPic = callMap['caller_pic'];
   this.receiverName =  callMap['receiver_name'];
   this.receiverid = callMap['receiver_id'];
   this.receiverPic = callMap['receiver_pic'];
   this.channelid = callMap['channel_id'];
   this.hasDailed =  callMap['has-dialed'];
 }
}

