import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicator extends StatelessWidget {
  LoadingIndicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content:
        SpinKitRotatingCircle(
      color: Colors.white,
      size: 50.0,
    ));
  }
}
