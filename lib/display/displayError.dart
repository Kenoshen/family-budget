import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DisplayError extends StatelessWidget {
  final dynamic error;

  DisplayError(this.error);

  @override
  Widget build(BuildContext context) {
    List<String> sb = [];
    context.visitAncestorElements((element) {
      sb.add(element.toStringShort());
      return sb.length < 10;
    });
    String stack = sb.reversed.toList().join("->\n");
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(30),
              child: Text(
                "$error",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                stack,
                style: TextStyle(
                  fontSize: 15,
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
