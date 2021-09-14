import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'call.dart';
import 'callMethods.dart';
import 'callScreen.dart';



class PickUpScreen extends StatelessWidget {
  final Call call;
  PickUpScreen({this.call});
  final CallMethods callMethods = CallMethods();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Incoming...',
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
            SizedBox(height: 50.0,),
            Image.network(
              call.callerPic,
              height: 150.0,
              width: 150.0,
            ),
            SizedBox(height: 15.0,),
            Text(
              call.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 75,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(icon: Icon(Icons.call_end),
                    onPressed:() async{
                      await callMethods.endCall(call: call);
                    }
                    ),
                SizedBox(width: 25.0,),

                IconButton(icon: Icon(Icons.call),
                    onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> CallScreen(call:call)));
                    }
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
