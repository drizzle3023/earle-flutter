import 'package:flutter/material.dart';

import '../api-manager.dart';
import 'main-page.dart';
import 'package:Earle/libs/shared-preferences-helper.dart';
import 'package:Earle/libs/constants.dart';
import 'package:Earle/libs/global.dart';
import 'package:toast/toast.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 15);

  TextEditingController emailTEC = TextEditingController();
  final passwordTEC = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailTEC.text = Globals.shared.userEmail;
  }

//  CalData _objCalData;
  // List<Map<String, dynamic>> _objCaldatas;

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.fromLTRB(15.0, 12.0, 15.0, 12.0);

    final emailField = TextField(
      obscureText: false,
      style: style,
      controller: emailTEC,
      decoration: InputDecoration(
          contentPadding: padding,
          hintText: 'Email',
          fillColor: Colors.white,
          filled: true,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final passwordField = TextField(
      obscureText: true,
      style: style,
      controller: passwordTEC,
      decoration: InputDecoration(
          contentPadding: padding,
          fillColor: Colors.white,
          filled: true,
          hintText: 'Password',
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final loginButton = ClipRRect(
      borderRadius: BorderRadius.circular(30.0),
      child: Material(
          elevation: 5.0,
          color: Color(0xff01A0C7),
          child: MaterialButton(
              minWidth: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              onPressed: () {
                doLogin();
              },
              child: Text(
                'Login',
                textAlign: TextAlign.center,
                style: style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ))),
    );

    return Scaffold(
        body: WillPopScope(
            // onWillPop: () async => false,
            child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/login-background.png'),
                      fit: BoxFit.cover),
                ),
                child: SingleChildScrollView(
                  child: Container(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 40.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              SizedBox(
                                  height: 160.0,
                                  child: Image.asset('assets/logo.png',
                                      fit: BoxFit.cover)),
                              SizedBox(width: 25),
                              Text(
                                Constants.shared.appName,
                                style: style.copyWith(
                                    color: Colors.white, fontSize: 45),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 100.0,
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                emailField,
                                SizedBox(
                                  height: 10.0,
                                ),
                                passwordField,
                                SizedBox(
                                  height: 50.0,
                                ),
                                _isLoading == false
                                    ? loginButton
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ))));
  }

  doLogin() {
    if (emailTEC.text == null || emailTEC.text.toString() == "") {
      Toast.show("Please input your email address", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (passwordTEC.text == null || passwordTEC.text.toString() == "") {
      Toast.show("Please input your password", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      setState(() {
        _isLoading = true;
      });

      ApiManager.shared
          .doLogin(email: emailTEC.text, password: passwordTEC.text)
          .then((data) {
        if (data == MsgType.SUCCESS) {
          SharedPreferencesHelper.setUserData().then((data) {
            ApiManager.shared.getJobNumbers().then((msgType) {
              if (msgType == MsgType.SUCCESS) {
                if (Globals.shared.userRole == UserRole.SUPER) {
                  ApiManager.shared.getCompanyList();
                }
                setState(() {
                  _isLoading = false;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              } else {
                setState(() {
                  _isLoading = false;
                });
                Toast.show(Globals.shared.getErrorMessage(msgType), context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              }
            });
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          Toast.show(Globals.shared.getErrorMessage(data), context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    emailTEC.dispose();
    passwordTEC.dispose();
    super.dispose();
  }
}
