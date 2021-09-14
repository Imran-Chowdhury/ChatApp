
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telegram_clone/home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  SharedPreferences preferences;
  bool isLoggedin = false;
  bool isLoading = false;
  User Currentuser;

  @override
  void initState(){
    super.initState();
     isSignedIn();
  }

  void isSignedIn() async{
   setState(() {
     isLoading = true;
   });

   preferences = await SharedPreferences.getInstance();
   isLoggedin = await googleSignIn.isSignedIn();

   if(isLoggedin){
     Navigator.push(context, MaterialPageRoute(builder: (context)=>
         HomeScreen(CurrentUserId: preferences.getString('id'),)));
     // Navigator.pushNamed(context, 'HomeScreen');
   }
   setState(() {
     isLoading = false;
   });

  }





  Future<Null> controlSignIn()async{

    preferences = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleuser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleauth = await googleuser.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(   //passed the credentials to the firebase

      accessToken: googleauth.accessToken,

      idToken: googleauth.idToken,

    );

     final result = await firebaseAuth.signInWithCredential(credential); //saving the google credentials and signing in firebase database through a variable
    final user  = result.user;

    if(user != null){
      //check if user is already signedup
      final QuerySnapshot resultQuery = await firestore.collection('user').where('id', isEqualTo: user.uid).get();
      final List<DocumentSnapshot> documentSnapshots = resultQuery.docs;



      //saving data to the firestore if the user is new

      if(documentSnapshots.length ==0){
        firestore.collection('user').doc(user.uid).set({

          'nickname': user.displayName,
          'photoUrl' : user.photoURL,
          'id' : user.uid,
          'aboutme': 'Optimist',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'chattingWith': null,

        });

        //saving data to local database
        Currentuser = user;
        await preferences.setString('id',documentSnapshots[0]['id']);
        await preferences.setString('nickname',documentSnapshots[0]['nickname']);
        await preferences.setString('photoUrl',documentSnapshots[0]['photoUrl']);
        // await preferences.setString('aboutme',documentSnapshots[0]['aboutme']);



      }else{

        // Currentuser = user;

        await preferences.setString('id',documentSnapshots[0].data()['id']);
        await preferences.setString('nickname',documentSnapshots[0].data()['nickname']);
        await preferences.setString('photoUrl',documentSnapshots[0].data()['photoUrl']);
        await preferences.setString('aboutme',documentSnapshots[0].data()['aboutme']);

      }


      Fluttertoast.showToast(msg: 'Sign in successful');
      setState(() {
        isLoading= false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen(CurrentUserId: user.uid,CurrentUserName: user.displayName,CurrentUserPic: preferences.get('photoUrl'),)));
      print('the user name from home is ${user.displayName}');
      print('the user name from home is ${preferences.get('nickname')}');
      print('the user pic from home is ${user.photoURL}');
      print('the user pic from home is ${preferences.get('photoUrl')}');

    }else{

      Fluttertoast.showToast(msg: "Sign in failed");

      setState(() {
        isLoading= false;
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient:LinearGradient(
              begin:Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.lightBlueAccent,Colors.purpleAccent],
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Telegram Clone',
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 20.0,),
              GestureDetector(
                onTap: controlSignIn,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(20.0),
                        color: Colors.redAccent,
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 30.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 12.0),
                          child: Container(
                            child: isLoading? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.lightBlueAccent),) : Container() ,
                          ),
                      ),
                    ],
                  ),
                )
              ),
            ],
          ),
        ),
      );
  }
}


