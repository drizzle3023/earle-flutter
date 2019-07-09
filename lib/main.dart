import 'package:flutter/material.dart';
import 'dart:developer';

import 'package:flutter/scheduler.dart';

import 'pages/login-page.dart';
import 'pages/main-page.dart';
import 'libs/shared-preferences-helper.dart';
import 'libs/constants.dart';
import 'api-manager.dart';
import 'libs/global.dart';

void main() {
  SharedPreferencesHelper.getUserData().then((data) {
    if (Globals.shared.apiToken == '') {
      runApp(App(isLoggedIn: false));
    } else {
      ApiManager.shared.getJobNumbers().then((msgType) {
        if (msgType == MsgType.SUCCESS) {
          if (Globals.shared.userRole == UserRole.SUPER) {
            ApiManager.shared.getCompanyList().then((data) {
              runApp(App(isLoggedIn: true));
            });
          } else {
            runApp(App(isLoggedIn: true));
          }
        } else {
          runApp(App(isLoggedIn: false));
        }
      });
    }
  });
}

class App extends StatelessWidget {
  // This widget is the root of your application.
  final bool isLoggedIn;

  App({Key key, @required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
        return MaterialApp(
          title: Constants.shared.appName,
          routes: <String, WidgetBuilder> {
            '/login': (BuildContext context) => new LoginPage(),
            '/mainpage': (BuildContext context) => new MainPage(),
          },
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
          ),
          home: isLoggedIn == false ? LoginPage() : MainPage(),

        );
  }
}
