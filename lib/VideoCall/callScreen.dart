import 'package:flutter/material.dart';
import 'call.dart';
import 'pickupScreen.dart';
import 'callMethods.dart';

class CallScreen extends StatefulWidget {
  final Call call;
  final CallMethods callMethods =CallMethods();
  CallScreen({this.call});
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Call has been made',
            ),
            MaterialButton(
                color:Colors.red,
                child: Icon(Icons.call_end,
                  color: Colors.white,
                ),
                onPressed: (){
                  widget.callMethods.endCall(call:widget.call);
                  Navigator.pop(context);

                }
                 ),
          ],
        ),
      ),
    );
  }
}
