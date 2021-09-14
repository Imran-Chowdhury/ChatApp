import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telegram_clone/VideoCall/UserProvider.dart';
import 'package:telegram_clone/VideoCall/callMethods.dart';
import 'package:telegram_clone/VideoCall/pickupScreen.dart';
import 'call.dart';
import 'package:telegram_clone/chatPage.dart';

// class PickupLayout extends StatefulWidget {
//
//   Widget Called;
//
//
//   PickupLayout({this.Called});
//
//   @override
//   _PickupLayoutState createState() => _PickupLayoutState();
// }
//
// class _PickupLayoutState extends State<PickupLayout> {
//   User currentUser;
//
//   String uid;
//
//   Call call = Call();
//
//   void getCurrentUser()async{
//     User user = await FirebaseAuth.instance.currentUser;
//     if(user!=null){
//       currentUser=user;
//       uid = user.uid;
//     }
//   }
//   @override
//   void initState() {
//     // TODO: implement initState
//     getCurrentUser();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return (FirebaseFirestore.instance.collection('users').doc(uid).get()!=null)? StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
//         builder: (context,snapshot){
//           if(snapshot.hasData==null){
//             return CircularProgressIndicator();
//           }
//           final datas = snapshot.data.doc;
//           for(var data in datas){
//
//             final hasDialed = data.data()['hasDailed'];
//             final receiverId = data.data()['receiverid'];
//             print('the hasDialed property is $hasDialed');
//
//             if(!hasDialed){
//               return PickUpScreen(call: call);
//             }
//           }
//
//           return Chat();
//             //widget.Called;
//         }
//         ): Chat();
//   }
// }


// class PickupLayout extends StatelessWidget {
//
//   var userInfo = FirebaseFirestore.instance.collection('users').get();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }








// class PickupLayout extends StatelessWidget {
//
//   final Widget WillPopScope;
//   PickupLayout({this.WillPopScope});
//   CallMethods callMethods = CallMethods();
//   @override
//   Widget build(BuildContext context) {
//
//     // final UserProvider userProvider = Provider.of<UserProvider>(context);
//
//     return (userProvider!=null && userProvider.getUser!=null)
//         ?StreamBuilder(stream: callMethods.callStream(uid:userProvider.getUser.uid),
//         builder: (context,snapshot){
//           if(snapshot.hasData && snapshot.data.data!=null){
//            Call call = Call.fromMap(snapshot.data.data);
//             return PickUpScreen(call: call);
//           }
//           return WillPopScope;
//
//         }
//     )
//         : Center(
//                child: CircularProgressIndicator(),
//         );
//   }
// }
