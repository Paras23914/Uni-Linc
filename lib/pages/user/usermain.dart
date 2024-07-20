import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:college_dashboard/constant.dart';
import 'package:college_dashboard/pages/user/Chat/ChatApp.dart';
import 'package:college_dashboard/pages/user/dashboard.dart';
import 'package:college_dashboard/pages/user/profile.dart';
import 'package:college_dashboard/pages/user/userprofile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';

import 'home/homeScr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//import 'change_password.dart';
//import 'dashboard.dart';

class UserMain extends StatefulWidget {
  const UserMain({super.key});

  @override
  _UserMainState createState() => _UserMainState();
}

class _UserMainState extends State<UserMain> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final storage = const FlutterSecureStorage();

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    // const profile(),
    const Chat(),
    const UserProfile(),
    // const SettingPageUI(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: CurvedNavigationBar(
            height: 60,
            animationCurve: Curves.easeInOut,
            key: _bottomNavigationKey,
            index: 0,
            items: const <Widget>[
              Icon(
                Icons.home,
                color: Colors.yellowAccent,
              ),
              Icon(
                Icons.message,
                color: Colors.yellowAccent,
              ),
              Icon(
                CupertinoIcons.profile_circled,
                color: Colors.yellowAccent,
              )
            ],
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            buttonBackgroundColor: kBackgroundColor,
            backgroundColor: Colors.white,
            color: kBackgroundColor,
          )),
    );
  }
}
