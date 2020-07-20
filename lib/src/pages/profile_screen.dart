import 'dart:async';
import 'dart:convert';
import 'package:Seemly/src/components/PickerData.dart';
import 'package:Seemly/src/pages/chat_screen.dart';
import 'package:Seemly/src/pages/detail_screen.dart';
import 'package:Seemly/src/pages/login_screen.dart';
import 'package:Seemly/src/pages/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Seemly/src/components/rounded_button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'index.dart';

final _firestore = Firestore.instance;
final _auth = FirebaseAuth.instance;
String downloadURL;
String uid;
String web_url;

// TabController 객체를 멤버로 만들어서 상태를 유지하기 때문에 StatefulWidget 클래스 사용
class ProfileScreen extends StatefulWidget {
  static const String id = 'profile_screen';

  @override
  MyTabsState createState() => ppState;
}

MyTabsState ppState = MyTabsState();

// SingleTickerProviderStateMixin 클래스는 애니메이션을 처리하기 위한 헬퍼 클래스
// 상속에 포함시키지 않으면 탭바 컨트롤러를 생성할 수 없다.
// mixin은 다중 상속에서 코드를 재사용하기 위한 한 가지 방법으로 with 키워드와 함께 사용
class MyTabsState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  // 컨트롤러는 TabBar와 TabBarView 객체를 생성할 때 직접 전달
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  TabController controller;
  bool _hasCard = false;
  bool _hasWeb = false;
  bool _hasShop = false;
  bool _doTest = false;

  FirebaseUser loggedInUser;
  String crn;
  String value1;
  String data1;
  String value2;
  String data2;
  String url;
  var webList = [
    'https://www.16personalities.com/free-personality-test',
    'https://evecondoms.com/sex_mind_test/'
  ];

  void getProfile(String user) async {
    try {
      await Firestore.instance.collection('profile').getDocuments().then((ds) {
        ds.documents.forEach((element) {
          if (element.data['email'] == user)
            downloadURL = element.data['profile'];
        });
      });

      /*   fb.StorageReference firebaseStorageRef =
      await fb.storage().ref().child('profile/$user');
      final url = await firebaseStorageRef.getDownloadURL();
      var storageReference =
          await FirebaseStorage.instance.ref().child('profile/$user');
      final url = await storageReference.getDownloadURL();*/

      downloadURL ??=
          'https://firebasestorage.googleapis.com/v0/b/fir-91cdf.appspot.com/o/profile%2FGroup%20181.png?alt=media&token=cd21a44e-d09e-42cd-a3ed-206634b10691';
    } catch (e) {
      print(e);
      downloadURL =
          'https://firebasestorage.googleapis.com/v0/b/fir-91cdf.appspot.com/o/profile%2FGroup%20181.png?alt=media&token=cd21a44e-d09e-42cd-a3ed-206634b10691';
    }
  }

  showPickerSpinner(BuildContext context, List data) {
    Picker(
        adapter: PickerDataAdapter<String>(pickerdata: data),
        hideHeader: true,
        title: Text("추가할 심리테스트"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          data1 = (value[0].toString());
          print(data1);
          var temp = picker.getSelectedValues();
          value1 = temp[0].toString();
          print(value1);
          web_url = webList[value[0]];
          ppState._hideCard();
          ppState._showCard();
        }).showDialog(context);
  }

  showResultPicker(BuildContext context, List data) {
    Picker(
        adapter: PickerDataAdapter<String>(pickerdata: data),
        hideHeader: true,
        title: Text("Select Data"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          data2 = value[0].toString();
          print(data2);
          var temp = picker.getSelectedValues();
          value2 = temp[0].toString();
          print(value2);
          ppState._hideCard();
          ppState._showCard();
        }).showDialog(context);
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        crn = loggedInUser.email;
        getProfile(crn);
      }
    } catch (e) {
      print(e);
      await Navigator.pushNamed(context, WelcomeScreen.id);
    }
  }

  // 객체가 위젯 트리에 추가될 때 호출되는 함수. 즉, 그려지기 전에 탭바 컨트롤러 샛성.
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    _hasCard = false;
    _hasShop = false;
    _doTest = false;
    // SingleTickerProviderStateMixin를 상속 받아서
    // vsync에 this 형태로 전달해야 애니메이션이 정상 처리된다.
    controller = TabController(vsync: this, length: 4);
  }

  // initState 함수의 반대.
  // 위젯 트리에서 제거되기 전에 호출. 멤버로 갖고 있는 컨트롤러부터 제거.
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = new List();
    children.add(_buildBackground());
    if (_hasCard) children.add(_buildCard());
    if (_hasShop) children.add(_buildShop());
    if (_hasWeb) children.add(_buildWeb());
    return MaterialApp(
      home: Stack(
        children: children,
      ),
    );
  }

  Widget _buildBackground() => Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Color.fromRGBO(240, 255, 146, 1),
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.cancel),
                color: Color.fromRGBO(88, 115, 255, 1),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              backgroundColor: Color.fromRGBO(240, 255, 146, 1),
              elevation: 0.0,
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Color.fromRGBO(88, 115, 255, 1),
                    ),
                    onPressed: () {
                      ppState._showShop();
                    }),
              ],
              bottom: TabBar(
                  indicatorPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  controller: controller,
                  // 컨트롤러 연결
                  labelColor: Color.fromRGBO(88, 115, 255, 1),
                  indicatorColor: Color.fromRGBO(88, 115, 255, 1),
                  indicatorWeight: 3,
                  unselectedLabelColor: Colors.black,
                  labelPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  tabs: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Text(
                        'My Seemly',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Text(
                        '문자채팅',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                      child: Text(
                        '영상채팅',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    Text(' '),
                  ]),
            ),
            body: TabBarView(controller: controller, // 컨트롤러 연결
                children: [Red(), Green(), Blue(), Container()]),
          ),
          (_hasCard || _hasShop || _hasWeb
              ? Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 6),
                    child: Container(color: Color.fromRGBO(62, 52, 52, 0.1)),
                  ),
                )
              : Container()),
        ],
      );

  void _showCard() {
    setState(() => _hasCard = true);
  }

  void _hideCard() {
    setState(() => _hasCard = false);
  }

  void _showShop() {
    setState(() => _hasShop = true);
  }

  void _hideShop() {
    setState(() => _hasShop = false);
  }

  void _showWeb() {
    setState(() => _hasWeb = true);
  }

  void _hideWeb() {
    setState(() => _hasWeb = false);
  }

  void doTest() {
    setState(() => _doTest = false);
  }

  void doneTest() {
    setState(() => _doTest = true);
  }

  Widget _buildCard() => StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('profile')
          .where('email', isEqualTo: loggedInUser.email)
          .limit(1)
          .snapshots(),
      /*_firestore
          .collection('profile')
          .where('email', isEqualTo: loggedInUser.email)
          .limit(1)
          .snapshots(),*/
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        } else {
          var data;
          snapshot.data.documents.forEach((element) {
            if (element.data['email'] == loggedInUser.email) {
              data = element;
            }
          });
          print("데이터는");
          print(data);
          var name = data['name'];
          var lastTest = data['lastTest'];
          var profile = data['profile'];
          var phone = data['phone'];
          var tag1 = data['tag1'];
          var tag2 = data['tag2'];
          var tagList = <Widget>[];

          return Center(
            child: Container(
              width: 339,
              height: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
              child: Column(children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(30, 50, 8, 8),
                  child: Text(
                    name + '님의 \n심리보관소를\n채워봐요.',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color.fromRGBO(61, 52, 52, 1),
                        fontFamily: 'Apple SD Gothic Neo',
                        fontSize: 24,
                        letterSpacing: 0),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(30, 100, 20, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '추가할 심리테스트 목록',
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Apple SD Gothic Neo',
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(62, 52, 52, 1),
                        letterSpacing: 0),
                  ),
                ),
                (ppState.value1 != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              _showWeb();
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(30, 5, 0, 0),
                              child: Text(
                                ppState.value1,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Apple SD Gothic Neo',
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(62, 52, 52, 0.5),
                                    letterSpacing: 0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              color: Color.fromRGBO(220, 220, 255, 1),
                              child: Text(
                                'Select',
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                    fontSize: 15,
                                    fontFamily: 'Apple SD Gothic Neo',
                                    letterSpacing: 0),
                              ),
                              onPressed: () {
                                ppState.showPickerSpinner(
                                    context, ['내 MBTI는?', '나와 어울리는 SEX 타입?']);
                              },
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          color: Color.fromRGBO(220, 220, 255, 1),
                          child: Text(
                            'Select',
                            style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 15,
                                fontFamily: 'Apple SD Gothic Neo',
                                letterSpacing: 0),
                          ),
                          onPressed: () {
                            ppState.showPickerSpinner(
                                context, ['내 MBTI는?', '나와 어울리는 SEX 타입?']);
                          },
                        ),
                      )),
                Divider(
                  color: Color.fromRGBO(62, 52, 52, 0.2),
                  height: 12,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(30, 10, 20, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '나의 Seemly',
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Apple SD Gothic Neo',
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(62, 52, 52, 1),
                        letterSpacing: 0),
                  ),
                ),
                (ppState.value2 != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(30, 5, 0, 0),
                            child: Text(
                              ppState.value2,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Apple SD Gothic Neo',
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(62, 52, 52, 0.5),
                                  letterSpacing: 0),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              color: Color.fromRGBO(220, 220, 255, 1),
                              child: Text(
                                'Select',
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 1),
                                    fontSize: 15,
                                    fontFamily: 'Apple SD Gothic Neo',
                                    letterSpacing: 0),
                              ),
                              onPressed: () {
                                (int.parse(data1.toString()) == 0
                                    ? ppState.showResultPicker(context, [
                                        'INTJ',
                                        'INFJ',
                                        'ISTJ',
                                        'ISTP',
                                        'INTP',
                                        'INFP',
                                        'ESFJ',
                                        'ESFP',
                                        'ENTJ',
                                        'ENFJ',
                                        'ESTJ',
                                        'ESTP',
                                        'ENTP',
                                        'ENFP',
                                        'ESFJ',
                                        'ESFP'
                                      ])
                                    : ppState.showResultPicker(context, [
                                        '섹스계의 흥선대원군',
                                        '헌신적인 섹스매니저',
                                        '철벽의 섹크라테스',
                                        '오르가즘 건축학도',
                                        '관능적인 섹자이너',
                                        '침대위의 性인군자',
                                        '꿈꾸는 섹스칼럼리스트',
                                        '박학다식 사피오섹슈얼',
                                        '정력뿜뿜 섹스탐험가',
                                        '찐팔섹조 섹퍼스타',
                                        '호기심만렙 섹스실험가',
                                        '정욕의 섹시오패스',
                                        '오르가즘 마에스트로',
                                        '허니스위트 섹블리',
                                        '섹스계의 레지스탕스',
                                        '무소불위 섹통령'
                                      ]));
                              },
                            ),
                          ),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          color: Color.fromRGBO(220, 220, 255, 1),
                          child: Text(
                            'Select',
                            style: TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 15,
                                fontFamily: 'Apple SD Gothic Neo',
                                letterSpacing: 0),
                          ),
                          onPressed: () {
                            (int.parse(data1.toString()) == 0
                                ? ppState.showResultPicker(context, [
                                    'INTJ',
                                    'INFJ',
                                    'ISTJ',
                                    'ISTP',
                                    'INTP',
                                    'INFP',
                                    'ESFJ',
                                    'ESFP',
                                    'ENTJ',
                                    'ENFJ',
                                    'ESTJ',
                                    'ESTP',
                                    'ENTP',
                                    'ENFP',
                                    'ESFJ',
                                    'ESFP'
                                  ])
                                : ppState.showResultPicker(context, [
                                    '섹스계의 흥선대원군',
                                    '헌신적인 섹스매니저',
                                    '철벽의 섹크라테스',
                                    '오르가즘 건축학도',
                                    '관능적인 섹자이너',
                                    '침대위의 性인군자',
                                    '꿈꾸는 섹스칼럼리스트',
                                    '박학다식 사피오섹슈얼',
                                    '정력뿜뿜 섹스탐험가',
                                    '찐팔섹조 섹퍼스타',
                                    '호기심만렙 섹스실험가',
                                    '정욕의 섹시오패스',
                                    '오르가즘 마에스트로',
                                    '허니스위트 섹블리',
                                    '섹스계의 레지스탕스',
                                    '무소불위 섹통령'
                                  ]));
                          },
                        ),
                      )),
                Divider(
                  color: Color.fromRGBO(62, 52, 52, 0.2),
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                        child: Text('이전으로'),
                        onPressed: () {
                          _hideCard();
                        }),
                    RaisedButton(
                        child: Text('심리채우기'),
                        onPressed: () {
                          if (data1 != null) {
                            var tag = 'tag' +
                                (int.parse(data1.toString()) + 1).toString();
                            var id;
                            snapshot.data.documents.forEach((element) {
                              if (element['email'] == loggedInUser.email)
                                id = element.documentID;
                            });
                            _firestore
                                .collection('profile')
                                .document(id)
                                .updateData({tag: value2});
                          }
                          doneTest();
                          _hideCard();
                        }),
                  ],
                ),
              ]),
            ),
          );
        }
      });

  Widget _buildWeb() => Center(
      child: Container(
              margin: EdgeInsets.fromLTRB(20,20,20,20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: Color.fromRGBO(255, 255, 255, 1),
              ),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.all(10),
                    child: ClipOval(
                      child: Material(
                        color: Colors.white10, // button color
                        child: InkWell(
                          splashColor: Colors.red, // inkwell color
                          child: SizedBox(
                              width: 56, height: 56, child: Icon(Icons.backspace)),
                          onTap: () {
                            _hideWeb();
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                        height:450,
                        color: Colors.blue,
                        child: WebView(
                          key: UniqueKey(),
                          initialUrl: web_url,
                          javascriptMode: JavascriptMode.unrestricted,
                        )),
                ],
              )
              ),
      );

  Widget _buildShop() => Center(
        child: Container(
            width: 339,
            height: 600,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            child: Container(
                child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(30, 30, 8, 8),
                  child: Text(
                    '마스크 \n충전하기',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color.fromRGBO(61, 52, 52, 1),
                        fontFamily: 'Apple SD Gothic Neo',
                        fontSize: 24,
                        letterSpacing: 0),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
                  child: Text(
                    '현재 마스크 수',
                    style: TextStyle(
                        color: Color.fromRGBO(62, 52, 52, 1),
                        fontSize: 15,
                        fontFamily: 'Apple SD Gothic Neo',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(30, 12, 30, 0),
                  child: Row(children: <Widget>[
                    Container(
                        height: 30,
                        width: 30,
                        child: Image.asset('images/shop/icon_mask.png')),
                    Container(
                        padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                        alignment: Alignment.centerLeft,
                        height: 30,
                        child: Text(
                          'X N',
                          style: TextStyle(
                              color: Color.fromRGBO(141, 141, 141, 1),
                              fontFamily: 'Miriam Libre',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0),
                        ))
                  ]),
                ),
                Divider(
                  color: Color.fromRGBO(62, 52, 52, 0.2),
                  height: 36,
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                  child: Text(
                    '코인 구매',
                    style: TextStyle(
                        color: Color.fromRGBO(62, 52, 52, 1),
                        fontSize: 15,
                        fontFamily: 'Apple SD Gothic Neo',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(30, 15, 30, 0),
                  child: Row(
                    children: <Widget>[
                      Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                              height: 135,
                              child: Image.asset('images/shop/item1.png')),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  print('s');
                                },
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3),
                        child: Stack(
                          children: <Widget>[
                            Container(
                                height: 135,
                                child: Image.asset('images/shop/item2.png')),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    print('s2');
                                  },
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: <Widget>[
                          Container(
                              height: 135,
                              child: Image.asset('images/shop/item3.png')),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  print('s3');
                                },
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Color.fromRGBO(62, 52, 52, 0.2),
                  height: 36,
                ),
                RaisedButton(
                    child: Text('이전으로'),
                    onPressed: () {
                      _hideShop();
                    }),
              ],
            ))),
      );
}

// Card 위젯 구현
class Red extends StatefulWidget {
  @override
  RedState createState() => RedState();
}

class RedState extends State<Red> {
  String downloadURL;
  bool doTest = false;

  FirebaseUser crn;
  String email;
  @override
  initState() {
    super.initState();
    getCurrentUser();
  }

  void doneTest() {
    doTest = true;
    print(doTest);
  }

  void getProfile(String user) async {
    try {
      /*
      print("rwa");
      fb.StorageReference storageRef = fb.storage().ref('profile').child("profile");;

      Uri imageUri = await storageRef.getDownloadURL();
*/

      Uri imageUri;
      print(imageUri);
      print(imageUri.toString());
      downloadURL = imageUri.toString();
    } catch (e) {
      print(e);
      downloadURL =
          'https://firebasestorage.googleapis.com/v0/b/fir-91cdf.appspot.com/o/profile%2FGroup%20181.png?alt=media&token=cd21a44e-d09e-42cd-a3ed-206634b10691';
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        crn = user;
        getProfile(crn.email);
        email = crn.email;
      }
    } catch (e) {
      print(e);
      await Navigator.pushNamed(context, WelcomeScreen.id);
    }
  }

  // 객체가 위젯 트리에 추가될 때 호출되는 함수. 즉, 그려지기 전에 탭바 컨트롤러 샛성.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('profile').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          } else {
            var data;
            snapshot.data.documents.forEach((element) {
              if (element.data['email'] == email) {
                data = element;
              }
            });
            print(data);
            var name = data['name'];
            var lastTest = data['lastTest'];
            var profile = data['profile'];
            var phone = data['phone'];
            var tag1 = data['tag1'];
            var tag2 = data['tag2'];
            var tagList = <Widget>[];
            if (tag1 != null) {
              tagList.add(Container(
                padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.black12,
                ),
                child: Text(
                  tag1,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ));
            }
            if (tag2 != null) {
              tagList.add(Container(
                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                  margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.black12,
                  ),
                  child: Text(
                    tag2,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  )));
            }

            var tagStorage = <Widget>[];

            if (tag1 != null) {
              tagStorage.add(Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text('내 MBTI?')),
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text(
                        tag1,
                        textAlign: TextAlign.right,
                      )),
                ],
              )));
            }
            if (tag2 != null) {
              tagStorage.add(Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text('내 SEX 성향?')),
                  Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Text(
                        tag2,
                        textAlign: TextAlign.right,
                      )),
                ],
              )));
            }
            print(name);
            print('테스트');
            print(lastTest);
            return SingleChildScrollView(
              child: Column(children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  margin: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                        child: CircleAvatar(
                          radius: 32,
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: profile != null
                                ? NetworkImage(profile)
                                : AssetImage('images/auth/logo2.png'),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.centerLeft,
                              height: 20,
                              margin: EdgeInsets.fromLTRB(20, 0, 30, 10),
                              child: Text(
                                (name ?? 'Null'),
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800),
                              )),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            height: 20.0,
                            width: 200,
                            child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: (tagList.length != 0
                                    ? tagList
                                    : [Text('심리테스트를 시작하세요!')])),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: (ppState._doTest == false)
                      ? Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Text(
                                '오늘의 심리가 ' + (name ?? 'Null') + '님을 기다려요!',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Apple SD Gothic Neo',
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0),
                              ),
                            ),
                            Container(
                                height: 100,
                                width: double.infinity,
                                child: Image.asset(
                                    'images/main/main_waiting.png')),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 50),
                                color: Color.fromRGBO(88, 114, 255, 1),
                                onPressed: () {
                                  ppState._showCard();
                                },
                                child: Text(
                                  '오늘의 마스크 6개 받기',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Apple SD Gothic Neo',
                                      letterSpacing: 0),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              '내일의 심리를 기다려주세요!',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Apple SD Gothic Neo',
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0),
                            ),
                          ),
                          Container(
                              height: 100,
                              width: double.infinity,
                              child: Image.asset('images/main/main_logo.png')),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              color: Color.fromRGBO(88, 114, 255, 1),
                              child: Text(
                                '내일 또 봐요!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'Apple SD Gothic Neo',
                                    letterSpacing: 0),
                              ),
                            ),
                          ),
                        ]),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                  margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(20, 40, 50, 20),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '내 심리 보관소',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ] +
                        (tagStorage.isNotEmpty
                            ? tagStorage
                            : [Text('심리테스트를 시작하세요!')]) +
                        <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              color: Color.fromRGBO(222, 227, 255, 1),
                              onPressed: () {
                                ppState._showCard();
                              },
                              child: Text(
                                '+ 심리보관소 더 채우기',
                                style: TextStyle(
                                    color: Color.fromRGBO(88, 115, 255, 1),
                                    fontSize: 15,
                                    fontFamily: 'Apple SD Gothic Neo',
                                    letterSpacing: 0),
                              ),
                            ),
                          ),
                        ],
                  ),
                ),
              ]),
            );
          }
        });
  }
}

// Text 위젯 구현
class Green extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(20, 50, 20, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              color: Colors.white,
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '바로\n채팅하러\n가기',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Apple SD Gothic Neo',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      height: 80,
                                      child: Image.asset(
                                          'images/main/icon_random.png')),
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              ppState.context, ChatScreen.id);
                                        },
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      height: 80,
                                      child: Image.asset(
                                          'images/main/icon_men.png')),
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              ppState.context, ChatScreen.id);
                                        },
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      height: 80,
                                      child: Image.asset(
                                          'images/main/icon_women.png')),
                                  Positioned.fill(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              ppState.context, ChatScreen.id);
                                        },
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Card(
              elevation: 0.3,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      '광고주를 모집 중이에요!',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Apple SD Gothic Neo',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0),
                    ),
                  ),
                  Container(
                      height: 100,
                      width: double.infinity,
                      child: Image.asset('images/main/main_logo.png')),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      color: Color.fromRGBO(88, 114, 255, 1),
                      onPressed: () {
                        ppState._showCard();
                      },
                      child: Text(
                        'AD',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'Apple SD Gothic Neo',
                            letterSpacing: 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              color: Colors.white,
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 40, 50, 20),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '내 채팅목록',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ] +
                    <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 50),
                          color: Color.fromRGBO(222, 227, 255, 1),
                          onPressed: () {
                            Navigator.pushNamed(ppState.context, ChatScreen.id);
                          },
                          child: Text(
                            '채팅창 바로가기',
                            style: TextStyle(
                                color: Color.fromRGBO(88, 115, 255, 1),
                                fontSize: 15,
                                fontFamily: 'Apple SD Gothic Neo',
                                letterSpacing: 0),
                          ),
                        ),
                      ),
                    ],
              ),
            ),
          ),
        ],
      ),
    );
    Container(
      child: InkWell(
          child: Center(
              child: Text('GREEN',
                  style: TextStyle(fontSize: 31, color: Colors.white))),
          onTap: () async {
            Navigator.pushNamed(ppState.context, ChatScreen.id);
          }),
      color: Colors.green,
      margin: EdgeInsets.all(6.0),
    );
  }
}

// Icon 위젯 구현
class Blue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 100, 20, 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            alignment: Alignment.centerLeft,
            child: Text(
              '바로\n영상채팅\n하러가기',
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Apple SD Gothic Neo',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.0),
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 0,
                    color: Colors.white.withOpacity(1),
                    onPressed: () {
                      Navigator.pushNamed(ppState.context, IndexPage.id);
                    },
                    child: Container(
                        height: 80,
                        child: Image.asset('images/main/icon_random.png')),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.0),
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 0,
                    color: Colors.white.withOpacity(1),
                    onPressed: () {
                      Navigator.pushNamed(ppState.context, IndexPage.id);
                    },
                    child: Container(
                        height: 80,
                        child: Image.asset('images/main/icon_men.png')),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.0),
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    elevation: 0,
                    color: Colors.white.withOpacity(1),
                    onPressed: () {
                      Navigator.pushNamed(ppState.context, IndexPage.id);
                    },
                    child: Container(
                        height: 80,
                        child: Image.asset('images/main/icon_women.png')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Stream<Map<String, String>> getData() async* {
  var messagesStream = _firestore
      .collection('profile')
      .where('email', isEqualTo: loggedInUser.email)
      .snapshots();
  var messages = <String, String>{};
  print('a');
  messagesStream.listen(
      (data) => data.documents.forEach((doc) => doc.data.forEach((key, value) {
            messages[key] = value;
          })));
  print(messages);
  print(messages);
  yield messages;
}
