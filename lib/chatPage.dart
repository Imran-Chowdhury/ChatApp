

import 'dart:ffi';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telegram_clone/VideoCall/UserProvider.dart';
import 'package:telegram_clone/VideoCall/pickup_layout.dart';
import 'VideoCall/callUtilities.dart';
import 'package:telegram_clone/VideoCall/callScreen.dart';
import 'package:provider/provider.dart';
import 'VideoCall/UserProvider.dart';
import 'VideoCall/pickupScreen.dart';
import 'VideoCall/call.dart';


class PickupLayout extends StatefulWidget {
  String receivername;
  String receiverId;
  String receiverPic;
  Widget Scaffold;
  PickupLayout({this.receiverId,this.receiverPic,this.receivername,this.Scaffold});
  @override
  _PickupLayoutState createState() => _PickupLayoutState();
}

class _PickupLayoutState extends State<PickupLayout> {

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

  @override
  void initState() {
    getCurrentUser();
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: documentSnapshots,
    builder: (context,snapshot){
        if(snapshot.hasData && uid==widget.receiverId){
          Call call = Call.fromMap(snapshot.data);
          return PickUpScreen(call: call,);
          // Navigator.push(context, MaterialPageRoute(builder: (context)=>PickUpScreen()));
        }
        return widget.Scaffold;

    }
    );
  }
}


// @override
// Widget build(BuildContext context) {
//   return (documentSnapshots==null)?StreamBuilder(
//       stream: documentSnapshots,
//       builder: (context,snapshot){
//         if(snapshot.hasData){
//           return CircularProgressIndicator();
//         }
//         return Chat();
//       }
//   ): StreamBuilder(stream:documentSnapshots,
//       builder: (context,snapshot){
//         if(!snapshot.hasData){
//           return CircularProgressIndicator();
//         }
//         final callerName = snapshot.data()['callerName'];
//         final callerId = snapshot.data()['callerid'];
//         if(callerId!=uid){
//           return PickUpScreen();
//         }
//       }
//   );
// }
// }



class Chat extends StatelessWidget {

  final String receiverId;
  final String receiverAvatar;
  final String receiverName;
  final String senderId;
  final String senderPic;
  final String senderName;
  final CallUtils callUtils = CallUtils();



  Chat({this.receiverId,this.receiverAvatar,this.receiverName,this.senderId,this.senderPic,this.senderName});



  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      Scaffold: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.lightBlue,
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.all(0.0),
                child: IconButton(
                  icon: Icon(Icons.video_call),
                  onPressed: ()async{
                     await callUtils.dial(senderId: senderId,senderName: senderName,senderPic: senderPic,
                         receiverName: receiverName,receiverId: receiverId,receiverAvatar: receiverAvatar,context:context,);

                  },
                ),
              ),
              Padding(
                padding:EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(receiverAvatar),
                ),
              )
            ],
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
           title: Text(
             receiverName,
             style: TextStyle(
               color: Colors.white,
               fontWeight: FontWeight.bold,
             ),
           ),
             centerTitle: true,


          ),
          body: ChatScreen(receiverAvatar: receiverAvatar,receiverId: receiverId,idOfsender: senderId,),
        ),
    );

  }
}


class ChatScreen extends StatefulWidget {
  String receiverId;
  String receiverAvatar;
  String idOfsender;
  ChatScreen({this.receiverAvatar,this.receiverId,this.idOfsender});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}


class _ChatScreenState extends State<ChatScreen> {

  TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isDisplaySticker;
  bool isLoading;
  String msgtext;
  File image;
  bool uploaded=false;
  String downloadUrl;
  // String filename = DateTime.now().millisecondsSinceEpoch.toString();
  // Reference storageReference = FirebaseStorage.instance.ref().child(filename);
  User CurrentUser;
  UserProvider userProvider;

  String uid;

  FirebaseAuth auth = FirebaseAuth.instance;

  void getCurrentUser()async{
    User user= await auth.currentUser;
    if(user!=null){
      CurrentUser = user;
      uid = CurrentUser.uid;
      print('the uid is $uid');
    }
  }
  // Reference storageReference = FirebaseStorage.instance.ref().child();





  @override
  void initState() {
    // TODO: implement initState
    getCurrentUser();
    // SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    //   userProvider = Provider.of<UserProvider>(context);
    //   userProvider.refreshUser();
    // });

    focusNode.addListener(onFocusChange);
    isDisplaySticker = false;
    isLoading= false;
  }

  onFocusChange(){
    if(focusNode.hasFocus){
      //hide sticker whenever keypad appears
      setState(() {
        isDisplaySticker = false;
      });
    }
  }
  
  Future getImage()async{
    PickedFile pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
   File imagefile = File(pickedFile.path);
    
    if(imagefile!=null){
      setState(() {
        image = imagefile;
        uploaded=true;
      });

    }
    uploadImageTofirestoreAndstorage();
  }
  
  
  Future uploadImageTofirestoreAndstorage()async{
    String filename = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('messagefolder').child(filename);

    UploadTask uploadTask = storageReference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() =>downloadImage(storageReference));
    // downloadImage();
  }

  Future downloadImage(Reference reference)async{
    String downloadAddress =  await reference.getDownloadURL();
    setState(() {
      downloadUrl = downloadAddress;
      print('The downloadUrl is $downloadUrl');
      FirebaseFirestore.instance.collection('user').doc(widget.idOfsender).collection(widget.receiverId).add({
        'receiverId': widget.receiverId,
        'text': downloadUrl,
        'time': FieldValue.serverTimestamp(),
        'type': 'url',

        // 'senderId':widget.idOfsender,
      });
      FirebaseFirestore.instance.collection('user').doc(widget.receiverId).collection(widget.idOfsender).add({
        'senderId': widget.receiverId,
        'text': downloadUrl,
        'time': FieldValue.serverTimestamp(),
        'type': 'url',

        // 'senderId':widget.idOfsender,
      });
    });
  }



   createInput(){
    return Container(
      child: Row(
        children: <Widget>[
          //pick image icon button
          Material(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                color: Colors.lightBlueAccent,
                onPressed: (){
                getImage();
                },
              ),
            ),
          ),

          //emoji icon button
          Material(
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                color: Colors.lightBlueAccent,
                onPressed:
                  getSticker,

              ),
            ),
          ),
          //Text Field
          Flexible(
            child: Container(
              child: TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
                onChanged: (value){
                  msgtext = value;
                },
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                    hintText: 'Write here...',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                    )
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          //Send message icon button

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal:8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                color: Colors.lightBlueAccent,
                onPressed: (){
                  print(msgtext);
                  textEditingController.clear();

                  FirebaseFirestore.instance.collection('user').doc(widget.idOfsender).collection(widget.receiverId).add({
                    'receiverId': widget.receiverId,
                    'text': msgtext,
                    'time': FieldValue.serverTimestamp(),
                    'type': 'text',

                    // 'senderId':widget.idOfsender,
                  });
                  FirebaseFirestore.instance.collection('user').doc(widget.receiverId).collection(widget.idOfsender).add({
                    'senderId': widget.receiverId,
                    'text': msgtext,
                    'time': FieldValue.serverTimestamp(),
                    'type': 'text',

                  });

                },
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
        color: Colors.white,
      ),
    );
  }

  void getSticker(){
    focusNode.unfocus();
    setState(() {
      isDisplaySticker = !isDisplaySticker;
    });
  }

  Future<bool> onBackPress(){
    if(isDisplaySticker){
      isDisplaySticker = false;
    }else{
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  createLoading(){
    return Positioned(
        child: isLoading? CircularProgressIndicator():Container()
    );
  }
//.orderBy('time', descending: false)
  CreateListofMessages(){
    return Flexible(
      child: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('user').doc(widget.idOfsender).collection(widget.receiverId).orderBy('time', descending: false).snapshots(),
          // FirebaseFirestore.instance.collection('conversations').snapshots(),
          builder: (context,snapshot){
            if(!snapshot.hasData){
              return CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              );
            }

            List<MessageBubble> messageList = [];
            final messages = snapshot.data.docs.reversed;
            for(var message in messages){
              var messageText = message.data()['text'];
              String receiverId = message.data()['receiverId'];
              // String messageSender = message.data()['nickname'];
              String senderId = message.data()['senderId'];
              final messageTime = message.data()['time'] as Timestamp;
              final messageType = message.data()['type'];
              print("the message text is $messageText");
              print('the message type is $messageType');




              if(widget.idOfsender==senderId||widget.receiverId==receiverId) {
                final messageWidgets = MessageBubble(
                  // sender: messageSender,
                  uploaded: uploaded,
                  messageType:messageType,
                  text: messageText,
                  time: messageTime,
                  senderId: senderId,
                  receiverId: receiverId,
                  uid: uid,
                );
                messageList.add(messageWidgets);
              }
            }
            return Expanded(
              child: ListView(
                reverse: true,
                padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                children: messageList,
              ),
            );
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return
      // PickupLayout(
      // WillPopScope:
      WillPopScope(
        onWillPop: onBackPress,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                //create list of messages

                 // CreateListofMessages(),

                CreateListofMessages(),


                //show emojis
                (isDisplaySticker? CreateSticker(): Container()),


                //Input Controllers
                createInput(),
              ],
            ),
            createLoading(),
          ],
        ),
      );
    // );
  }

}

class ButtonsForSticker extends StatelessWidget {

  int stickerNumber;

  ButtonsForSticker({this.stickerNumber});

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: null,
      child: Image.asset(
        'assets/images/mimi$stickerNumber.gif',
        width: 50.0,
        height: 50.0,
        fit: BoxFit.cover,
      ),
    );
  }
}

class CreateSticker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,

        children: <Widget>[
          //1st Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <ButtonsForSticker>[
              ButtonsForSticker(stickerNumber: 1),

              ButtonsForSticker(stickerNumber: 2,),

              ButtonsForSticker(stickerNumber: 3,),
            ],
          ),

          //2nd Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <ButtonsForSticker>[
              ButtonsForSticker(stickerNumber: 4,),

              ButtonsForSticker(stickerNumber: 5,),

              ButtonsForSticker(stickerNumber: 6,),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
          color: Colors.white
      ),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }
}


class MessageBubble extends StatelessWidget {
  // String sender;
  var text;
  bool uploaded;
  Timestamp time;
  String senderId;
  String receiverId;
  String uid;
  String messageType;
  MessageBubble({this.text,this.time,this.senderId,this.receiverId,this.uid,this.uploaded,this.messageType});




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: senderId==uid? CrossAxisAlignment.start:CrossAxisAlignment.end,
        children: <Widget>[

          messageType=='url'?    CachedNetworkImage(
            placeholder: (context,url) => Container(
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
              ),
              width: 200.0,
              height: 200.0,
              padding: EdgeInsets.all(20.0),
            ),
            imageUrl: text,
            //imageToDisplay,
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          )
              :

          Material(

            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            color:
            senderId!=uid?
            Colors.lightBlueAccent
                : Colors.grey,

             borderRadius:
             senderId==uid?
              BorderRadius.only(topRight: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0))
                 : BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)),
          )
        ],
      ),
    );
  }
}




