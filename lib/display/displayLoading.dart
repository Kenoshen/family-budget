import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DisplayLoading extends StatelessWidget {
  final String msg;

  DisplayLoading(this.msg);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                msg,
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
