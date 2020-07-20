import 'dart:io';

import 'package:Seemly/src/pages/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:Seemly/src/components/rounded_button.dart';
import 'package:Seemly/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;
  String name;
  String phone;
  String downloadURL;

  File _image;
  final picker = ImagePicker();

  Future _uploadImageToServer(String uid, File image) async {
    try {
      StorageReference firebaseStorageRef =
          await FirebaseStorage.instance.ref().child('profile/$uid');
      StorageUploadTask uploadTask = await firebaseStorageRef.putFile(image);
      await uploadTask.onComplete;

      downloadURL = await firebaseStorageRef.getDownloadURL();
    } catch (e) {
      downloadURL =
          'https://firebasestorage.googleapis.com/v0/b/fir-91cdf.appspot.com/o/profile%2FGroup%20181.png?alt=media&token=cd21a44e-d09e-42cd-a3ed-206634b10691';
    }
  }

  Future _uploadImageToStorage(ImageSource source) async {
    try {
      final image = await picker.getImage(source: source);
      setState(() {
        _image = File(image.path);
      });
    } catch (e) {
      print(e);
    }
  }

  void _register() async {
    final FirebaseUser newUser = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;

    if (newUser != null) {
      await _uploadImageToServer(newUser.email, _image);
    }

    await Firestore.instance.collection('profile').add({
      'email': email,
      'name': name,
      'phone': phone,
      'lastTest': Timestamp.now(),
      'profile': downloadURL,
    });
  }

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
              padding: EdgeInsets.fromLTRB(24, 200, 24, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                      height: 180.0,
                      child: Column(
                        children: <Widget>[
                          CircleAvatar(
                            radius: 50,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: (_image != null)
                                  ? FileImage(_image)
                                  : AssetImage('images/unnamed.jpg'),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              OutlineButton(
                                highlightedBorderColor: Colors.black54,
                                child: Text('갤러리'),
                                onPressed: () {
                                  _uploadImageToStorage(ImageSource.gallery);
                                },
                              ),
                              OutlineButton(
                                highlightedBorderColor: Colors.black54,
                                child: Text('카메라'),
                                onPressed: () {
                                  _uploadImageToStorage(ImageSource.camera);
                                },
                              )
                            ],
                          ),
                        ],
                      )),
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
                  SizedBox(
                    height: 26.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      name = value;
                    },
                    decoration:
                        kTextFieldDecoration.copyWith(hintText: '이름을 입력해주세요.'),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      phone = value;
                    },
                    decoration: kTextFieldDecoration.copyWith(
                        hintText: '핸드폰 번호를 입력해주세요.'),
                  ),
                  Flexible(
                    child: SizedBox(
                      height: 150.0,
                    ),
                  ),
                  RoundedButton(
                    title: '회원가입',
                    text: Colors.white,
                    colour: Color.fromRGBO(88, 114, 255, 1),
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        _register();
                        setState(() {
                          showSpinner = false;
                        });
                        await Navigator.pushNamed(context, WelcomeScreen.id);
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
