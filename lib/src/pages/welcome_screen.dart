import 'package:Seemly/src/pages/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:Seemly/src/pages/chat_screen.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:Seemly/src/components/rounded_button.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              child: Image.asset('images/auth/text_welcome.png'),
              height: 70.0,
            ),
            Container(
              child: Image.asset('images/auth/logo2.png'),
              height: 250.0,
              margin: EdgeInsets.fromLTRB(40, 28, 0, 38),
            ),
            Container(
              child: Image.asset('images/auth/text_description.png'),
              height: 60.0,
            ),
            SizedBox(
              height: 48.0,
            ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 5.0,
          onPressed: () {Navigator.pushNamed(context, LoginScreen.id);},
          color: Color.fromRGBO(88, 114, 255, 1),
          child: Text(
            '로그인',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
          ),
        ),
      ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 0.0),
              child: RaisedButton(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5.0,
                onPressed: () {Navigator.pushNamed(context, RegistrationScreen.id);},
                color: Color.fromRGBO(223, 227, 255, 1),
                child: Text(
                  '회원가입',
                  style: TextStyle(
                    color: Color.fromRGBO(88, 114, 255, 1),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
              child: InkWell(
                  child: Center(
                    child: Text(
                      '아이디/비밀번호를 잊어버리셨나요?',
                      style: TextStyle(
                        color: Color.fromRGBO(138, 157, 248, 1),
                      ),
                    ),
                  ),
                  onTap: () async {
                    await Navigator.pushNamed(context, RegistrationScreen.id);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
