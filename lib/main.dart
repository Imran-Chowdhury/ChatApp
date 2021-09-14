import 'package:flutter/material.dart';
import 'package:telegram_clone/home.dart';
import 'login.dart';
import 'settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:telegram_clone/VideoCall/UserProvider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
          home: LoginScreen(),
         debugShowCheckedModeBanner: false,
      );



  }
}


// MaterialApp(
// initialRoute: 'LoginScreen',
// routes: {
// 'LoginScreen':(context) => LoginScreen(),
// 'HomeScreen': (context)=>HomeScreen(),
// } ,
// );