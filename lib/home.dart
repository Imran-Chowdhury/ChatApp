


import 'chatPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/scheduler.dart';
import 'package:telegram_clone/VideoCall/UserProvider.dart';
import 'package:telegram_clone/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:telegram_clone/main.dart';
// import 'main.dart';
import 'package:telegram_clone/settings.dart';
import 'chatPage.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {

  final String CurrentUserId;
  final String CurrentUserPic;
  final String CurrentUserName;
  HomeScreen({this.CurrentUserId,this.CurrentUserName,this.CurrentUserPic});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  TextEditingController textEditingController = TextEditingController();
  Future<QuerySnapshot> futureSeachResult;
   String searchedUserName;

   // UserProvider userProvider;

  User loggedinUser;

  void getCurrentUser()async{
    final currentUser = await firebaseAuth.currentUser;
    if(currentUser!=null){
      loggedinUser=currentUser;
      print(loggedinUser.uid);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getCurrentUser();
    // userProvider.refreshUser();

    // SchedulerBinding.instance.addPostFrameCallback(() {
    //    userProvider =Provider.of<UserProvider>(context,listen: false);
    // });
    super.initState();
  }




  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blueAccent,
          actions: [
          IconButton(
              icon: Icon(Icons.arrow_back),
               onPressed:(){
               print('Icon Button Pressed');
               } // onPressed: logoutUser,
            ),
             IconButton(
                 icon: Icon(Icons.settings),
                 onPressed:(){
                   Navigator.push(context, MaterialPageRoute(builder: (context)=> Setting()));
                 }
             ),
          ],
          title: Container(
            margin: EdgeInsets.only(bottom: 4.0),
            child: TextField(
              style: TextStyle(
                color: Colors.black,
              ),
              onChanged: (value){
               setState(() {
                 searchedUserName = value.toLowerCase();
                 print(searchedUserName);
                 print(value);
               });
              },
              controller: textEditingController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                  onPressed: (){
                      textEditingController.clear();
                      // searchedUserName =null;
                  },
                ),
                hintText: 'Search Users',
                hintStyle: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

          ),
        ),
        body: Container(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('user').snapshots(),
             // FirebaseFirestore.instance.collection('users').where('searchIndex',arrayContains: searchedUserName),
              builder: (context,snapshot){
                if(!snapshot.hasData){
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                  );
                }
                final accounts = snapshot.data.docs;
                List<ListofAccounts> accountsList = [];
                for(var account in accounts){

                  final accountName = account.data()['nickname'];
                  final accountPicture = account.data()['photoUrl'];
                  final accountId = account.data()['id'];
                  print('the acc url is $accountPicture');
                  print('the accname is $accountName');
                  print('the acc id is $accountId');
                  print('THE SENDER NAME IS ${widget.CurrentUserName}');
                  final accList = ListofAccounts(accName: accountName,accPic: accountPicture,accId: accountId,senderID: widget.CurrentUserId,
                    senderName: widget.CurrentUserName,senderPic: widget.CurrentUserPic,);
                  if(widget.CurrentUserId!=accountId){
                    accountsList.add(accList);
                  }
                }
                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                  children:
                  accountsList,
                );

              }
          )
        ),
      ),
    );
  }
}




class ListofAccounts extends StatelessWidget {

  String accName;
  String accPic;
  String accId;
  String senderID;
  String senderPic;
  String senderName;


  ListofAccounts({this.accName,this.accPic,this.accId,this.senderID,this.senderName,this.senderPic});
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(4.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: (){

                Navigator.push(context, MaterialPageRoute(builder: (context) =>Chat(receiverId: accId,receiverAvatar: accPic,receiverName: accName,senderId:senderID,senderPic: senderPic,senderName: senderName,)),

                );

                PickupLayout(receiverId: accId,receivername: accName,receiverPic: accPic,);
                print('the sender pic is $senderPic');
                print('the sender name is $senderName');
                print('the sender id is $senderID');
              },

              child: ListTile(

                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(accPic),
                ),
                title: Text(
                     accName,

                  style:TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }
 
}


// final accounts = snapshot.data.docs;
// List<ListofAccounts> accountsList = [];
// for(var account in accounts){
//
// final accountName = account.data()['nickname'];
// final accountPicture = account.data()['photoUrl'];
// final accountId = account.data()['id'];
// print('the acc url is $accountPicture');
// print('the accname is $accountName');
// print('the acc id is $accountId');
// final accList = ListofAccounts(accName: accountName,accPic: accountPicture,accId: accountId,senderID: widget.CurrentUserId,);
// if(widget.CurrentUserId!=accountId){
//
// accountsList.add(accList);
// }
//
//
//
// }


  // i made for the list of users//

// StreamBuilder<QuerySnapshot>(
// stream: FirebaseFirestore.instance.collection('user').snapshots(),
// // FirebaseFirestore.instance.collection('users').where('searchIndex',arrayContains: searchedUserName),
// builder: (context,snapshot){
// if(!snapshot.hasData){
// return CircularProgressIndicator(
// valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
// );
// }
// final accounts = snapshot.data.docs;
// List<ListofAccounts> accountsList = [];
// for(var account in accounts){
//
// final accountName = account.data()['nickname'];
// final accountPicture = account.data()['photoUrl'];
// final accountId = account.data()['id'];
// print('the acc url is $accountPicture');
// print('the accname is $accountName');
// print('the acc id is $accountId');
// final accList = ListofAccounts(accName: accountName,accPic: accountPicture,accId: accountId,senderID: widget.CurrentUserId,);
// if(widget.CurrentUserId!=accountId){
// accountsList.add(accList);
// }
// }
// return ListView(
// padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
// children:
// accountsList,
// );
//
//
// }
// )


   //for search operation from tutorial//

// StreamBuilder<QuerySnapshot>(
// stream:(searchedUserName==null||searchedUserName.trim()=='')?FirebaseFirestore.instance.collection('user').snapshots()
//     : FirebaseFirestore.instance.collection('users').where('searchIndex',arrayContains: searchedUserName).snapshots(),
// builder: (context,snapshot){
// if(snapshot.hasError){
// return Text('We got an error ${snapshot.error}');
// }
// // final accounts = snapshot.data.docs;
//
// switch(snapshot.connectionState){
// case ConnectionState.waiting:
// return Center(
// child: CircularProgressIndicator(),
// );
// case ConnectionState.none:
// return Text('oops somethimg went wrong');
// case ConnectionState.done:
// return Text('yess done');
//
// default:
// return ListView(
// padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
// children:snapshot.data.docs.map((DocumentSnapshot document){
// return ListTile(
// title: Text(document.data()['nickname']),
// leading: CircleAvatar(
// backgroundColor: Colors.black,
// backgroundImage: CachedNetworkImageProvider(document.data()['photoUrl']),
// ),
// );
// }).toList()
// );
// }
// },
// )