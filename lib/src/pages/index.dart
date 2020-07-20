import 'dart:async';
import 'dart:ui';

import 'package:Seemly/src/pages/profile_screen.dart';
import 'package:Seemly/src/pages/welcome_screen.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import './call.dart';

class IndexPage extends StatefulWidget {
  static const String id = 'index_screen';

  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Stack(children: <Widget>[
          Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        "https://flutter-examples.com/wp-content/uploads/2020/02/dice.jpg"),
                    fit: BoxFit.cover)),
          ),
          Container(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 6),
              child: Container(
                  decoration: BoxDecoration(
                color: Colors.grey.shade100.withOpacity(0.2),
              )),
            ),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 80),
              child: CircleAvatar(
                radius: 96,
                child: CircleAvatar(
                  radius: 96,
                  backgroundImage: AssetImage('images/auth/logo2.png'),
                ),
              ),
            ),
          ),
    Container(
    padding: EdgeInsets.all(20),
    margin:EdgeInsets.fromLTRB(0, 500, 0, 0),
    child: Row(
    children: <Widget>[
    Expanded(
    child: RaisedButton(
    onPressed: onJoin,
    child: Text('Join'),
    color: Colors.blueAccent,
    textColor: Colors.white,
    ),
    )
    ],
    ),
    ),
        ]) /*Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    controller: _channelController,
                    decoration: InputDecoration(
                      errorText:
                          _validateError ? 'Channel name is mandatory' : null,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'Channel name',
                    ),
                  ))
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: Text(ClientRole.Broadcaster.toString()),
                    leading: Radio(
                      value: ClientRole.Broadcaster,
                      groupValue: _role,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(ClientRole.Audience.toString()),
                    leading: Radio(
                      value: ClientRole.Audience,
                      groupValue: _role,
                      onChanged: (ClientRole value) {
                        setState(() {
                          _role = value;
                        });
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: onJoin,
                        child: Text('Join'),
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),*/

        );
  }

  Future<void> onJoin() async {
    // update input validation
    /*setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {*/
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic();
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: '12',
            //channelName: _channelController.text,
            role: ClientRole.Broadcaster,
          ),
        ),
      );

  }

  Future<void> _handleCameraAndMic() async {
    print('get permission!');
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }
}
