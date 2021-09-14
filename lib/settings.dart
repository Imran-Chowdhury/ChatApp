import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class Setting extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.lightBlue,
          title: Text(
            'Account Settings',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SettingScreen(),
      ),
    );
  }
}



class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {

  SharedPreferences preferences;
  String id;
  String nickname;
  String aboutMe;
  String photoUrl;
  File ImageFileAvatar;



  bool isLoading = false;
  final FocusNode nicknamefocusNode = FocusNode();
  final FocusNode aboutmefocusNode = FocusNode();

  TextEditingController nicknametextEditingController;
  TextEditingController aboutMetextEditingController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readDataFromLocal();
  }

  void readDataFromLocal()async{
    preferences = await SharedPreferences.getInstance();

    id = await preferences.getString('id');
    nickname = await preferences.getString('nickname');
    aboutMe= await preferences.getString('aboutMe');
    photoUrl= await preferences.getString('photoUrl');

    nicknametextEditingController = TextEditingController(text: nickname);
    aboutMetextEditingController = TextEditingController(text: aboutMe);


    // Force refresh input
    setState(() {

    });

  }

  Future getimage()async{
    PickedFile pickedFile = await ImagePicker().getImage(source:ImageSource.gallery );
    File image = File(pickedFile.path);


    if(image != null){
     setState(() {
       ImageFileAvatar = image;
       isLoading = true;
     });
    }
    uploadImageToFirestoreAndStorage();
  }


  Future uploadImageToFirestoreAndStorage()async{

    String mFilename = id;

    FirebaseStorage storage = FirebaseStorage.instance;

    Reference storagereference = storage.ref().child(mFilename);
    UploadTask uploadTask = storagereference.putFile(ImageFileAvatar);
    TaskSnapshot taskSnapshot;
    uploadTask.then((value){
      if(value !=null) {
        taskSnapshot = value;
        taskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl) {
          photoUrl = newImageDownloadUrl;

          FirebaseFirestore.instance.collection('user').doc(id).update({
            'photoUrl': photoUrl,
            'aboutMe' : aboutMe,
            'nickname': nickname,
          }).then((data) async{
            await preferences.setString('photoUrl', photoUrl);
            await preferences.setString('aboutMe', aboutMe);
            await preferences.setString('nickname', nickname);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Updated Successfully");
          });
        }, onError: (errorMsg) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: errorMsg.toString());
        });
      }
      }, onError:(errorMsg){
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: errorMsg.toString());
      });
    }

    void UpdateData(){
    nicknamefocusNode.unfocus();
    aboutmefocusNode.unfocus();
    setState(() {
      isLoading = true;
    });
    List<String> splitList = nickname.split(' ');
    List<String> indexList = [];

    for(int i = 0; i<splitList.length; i++){
      for(int j =0; j<splitList[i].length+i;j++){
        indexList.add(splitList[i].substring(0,j).toLowerCase());
      }
    }

    FirebaseFirestore.instance.collection('user').doc(id).update({
      'photoUrl': photoUrl,
      'aboutMe' : aboutMe,
      'nickname': nickname,
      'searchIndex': indexList,
    }).then((data) async{
      await preferences.setString('photoUrl', photoUrl);
      await preferences.setString('aboutMe', aboutMe);
      await preferences.setString('nickname', nickname);
      // await preferences.setString('searchIndex', indexList);
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Updated Successfully");
    }).catchError((err){
      setState(() {
        isLoading=false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  // uploadData(String theName)async{
  //   List<String> splitList = theName.split(' ');
  //   List<String> indexList = [];
  //
  //   for(int i = 0; i<splitList.length; i++){
  //     for(int j =0; j<splitList[i].length+i;j++){
  //       indexList.add(splitList[i].substring(0,j).toLowerCase());
  //     }
  //   }
  //   FirebaseFirestore.instance.collection('users').doc(id).update(
  //     {
  //       'userName': theName,
  //       'searchIndex': indexList,
  //     }
  //   );
  // }
  //


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
                 Container(
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        (ImageFileAvatar == null)
                            ?(photoUrl != '')
                            ?Material(
                          //display already existing - old image file
                          child: CachedNetworkImage(
                            placeholder: (context,url) =>Container(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(20.0),
                            ),
                            imageUrl: photoUrl,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(125.0)),
                          clipBehavior: Clip.hardEdge,
                        )
                            : Icon(Icons.account_circle,color: Colors.grey,size: 90.0,)
                            :Material(
                          //diplaying the new updated image here
                          child: Image.file(
                            // ImageFileAvatar,
                            ImageFileAvatar,
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(125.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                    IconButton(
                      icon: Icon(Icons.camera_alt,size: 100.0,color: Colors.white54.withOpacity(0.3)),
                      onPressed: getimage,
                      padding: EdgeInsets.all(0.0),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.grey,
                      iconSize: 200.0,
                        ),
                      ],
                    ),
                  ),
                  width: double.infinity,
                  margin: EdgeInsets.all(20.0),
                ),

              //Input Fields
              Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(1.0),
                    child: isLoading? CircularProgressIndicator(): Container(),
                  ),


                  Container(
                    child: Text(
                        'Profile Name',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ) ,
                    ),
                    margin: EdgeInsets.only(left: 10.0,bottom: 10.0,top: 10.0),
                  ),

                  //UserName
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type name...',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: nicknametextEditingController,
                        onChanged: (name){
                          setState(() {
                            nickname = name;
                          });

                        },
                        focusNode: nicknamefocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0,right: 30.0),
                  ),

                  //aboutMe - userbio
                  Container(
                    child: Text(
                      'About Me',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                      ) ,
                    ),
                    margin: EdgeInsets.only(left: 10.0,bottom: 5.0,top: 30.0),
                  ),
                  //UserName
                  Container(
                    child: Theme(
                      data: Theme.of(context).copyWith(primaryColor: Colors.lightBlueAccent),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Bio..',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        controller: aboutMetextEditingController,
                        onChanged: (value){
                         setState(() {
                           aboutMe = value;
                         });
                        },
                        focusNode: aboutmefocusNode,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0,right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              //Update Button
              Container(
                child: FlatButton(
                  onPressed: UpdateData,
                  child: Text(
                    'Update',
                    style: TextStyle(
                      fontSize: 16.0
                    ),
                  ),
                  color: Colors.lightBlueAccent,
                  highlightColor: Colors.grey,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0,bottom: 1.0),
              ),

              //Logout Button
              Padding(
                padding: EdgeInsets.only(right: 50.0,left: 50.0),
                child: RaisedButton(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0
                    ),
                  ),
                  color: Colors.red,
                    onPressed: logoutUser ),
              ),

            ],
          ),
          padding: EdgeInsets.only(left: 15.0,right: 15.0),
        ),
      ],
    );
  }

  GoogleSignIn googleSignIn = GoogleSignIn();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future logoutUser()async{
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    setState(() {
      isLoading = false;
    });

    // Navigator.pop(context);
    // Navigator.pushNamed(context, 'LoginScreen');
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>MyApp()),(Route<dynamic>route)=>false);
  }
}

