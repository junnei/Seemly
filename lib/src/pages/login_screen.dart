import 'package:Seemly/src/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:Seemly/src/pages/chat_screen.dart';
import 'package:Seemly/src/components/rounded_button.dart';
import 'package:Seemly/constants.dart';
import 'package:Seemly/src/pages/registration_screen.dart';
import 'package:Seemly/src/pages/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/firebase.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            child: AppBar(
              title: Text(''), // You can add title here
              leading: IconButton(
                icon: Image.asset(
                  'images/auth/arrow_left.png',
                  height: 15,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor:
                  Colors.white.withOpacity(0), //You can make this transparent
              elevation: 0.0, //No shadow
            ),
          ),
          Center(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(0, 80, 0, 15),
                  height: 30.0,
                  child: Image.asset('images/auth/text_logo.png'),
                ),
                Container(
                  height: 60.0,
                  child: Image.asset('images/auth/icon_logo.png'),
                ),
              ],
            ),
          ),
          ModalProgressHUD(
            inAsyncCall: showSpinner,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 200,24,0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  /*Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      '심: 리',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38.0,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),*/
                  /*Flexible(
                    child: Hero(
                      tag: 'logo',
                      child: Container(
                        height: 250.0,
                        child: Image.asset('images/auth/logo.png'),
                      ),
                    ),
                  ),*/
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      email = value;
                    },
                    decoration:
                        kTextFieldDecoration.copyWith(hintText: '이메일을 입력해주세요.'),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      password = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: '비밀번호를 입력해주세요.'),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 150.0,
                    ),
                  ),
                  RoundedButton(
                    title: '로그인',
                    text: Colors.white,
                    colour: Color.fromRGBO(88, 114, 255, 1),
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        final user = await _auth.signInWithEmailAndPassword(
                            email: email, password: password);
                        if (user != null) {
                          print(context);
                          setState(() {
                            showSpinner = false;
                          });
                          await Navigator.pushNamed(context, ProfileScreen.id);
                        }
                      } catch (e) {
                        setState(() {
                          showSpinner = false;
                        });
                        print(e.toString());
                        print(e);
                      }
                    },
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
                          Navigator.pushNamed(context, RegistrationScreen.id);
                        }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
