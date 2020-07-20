import 'package:Seemly/src/pages/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:Seemly/src/pages/chat_screen.dart';
import 'package:Seemly/src/pages/login_screen.dart';
import 'package:Seemly/src/pages/registration_screen.dart';
import 'package:Seemly/src/pages/welcome_screen.dart';
import 'package:Seemly/src/pages/profile_screen.dart';
import './src/pages/index.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seemly_심:리',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: WelcomeScreen.id,
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        ChatScreen.id: (context) => ChatScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        IndexPage.id: (context) => IndexPage(),
      },
    );
  }
}
