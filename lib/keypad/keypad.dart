import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../model/currency.dart';

Future<double?> showKeypad(BuildContext context,
    {String title = "Enter Amount", String? subtitle}) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Keypad(title, subtitle: subtitle)),
  );
  return result;
}

class Keypad extends StatefulWidget {
  final String title;
  final String? subtitle;

  Keypad(this.title, {this.subtitle});

  @override
  _KeypadState createState() => _KeypadState();
}

class _KeypadState extends State<Keypad> {
  String text = "";
  bool isPositive = false;

  @override
  void initState() {
    super.initState();
    text = "";
    isPositive = false;
  }

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = widget.subtitle != null;
    final body = Scaffold(
      appBar: AppBar(
        title: Text(hasSubtitle ? widget.subtitle! : widget.title),
        leading: hasSubtitle ? Container() : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    format(),
                    style: TextStyle(
                      fontSize: 100,
                      color: isPositive ? Colors.lightGreen : Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                children: [
                  KeyRow([
                    SimpleKey("1", keypress),
                    SimpleKey("2", keypress),
                    SimpleKey("3", keypress),
                  ]),
                  KeyRow([
                    SimpleKey("4", keypress),
                    SimpleKey("5", keypress),
                    SimpleKey("6", keypress),
                  ]),
                  KeyRow([
                    SimpleKey("7", keypress),
                    SimpleKey("8", keypress),
                    SimpleKey("9", keypress),
                  ]),
                  KeyRow([
                    SimpleKey("-/+", togglePositive),
                    SimpleKey("0", keypress),
                    SimpleKey("Del", backspace),
                  ]),
                  KeyRow([SimpleKey("Done", (_) => done(context))]),
                ],
              ),
            )
          ],
        ),
      ),
    );

    if (hasSubtitle) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: body,
      );
    }
    return body;
  }

  void keypress(String char) {
    // don't allow 0's at the beginning of the text
    if (!(text.isEmpty && char == "0")) {
      setState(() {
        text += char;
      });
    }
  }

  void backspace(String _) {
    if (text.isNotEmpty) {
      setState(() {
        text = text.substring(0, text.length - 1);
      });
    }
  }

  void togglePositive(String _) {
    setState(() {
      isPositive = !isPositive;
    });
  }

  void done(BuildContext context) {
    Navigator.pop(context, amountFromFormat(format()));
  }

  String format() {
    var d = double.tryParse(text);
    if (d == null) {
      d = 0;
    }
    return (isPositive ? "+" : "-") + formatAmount(d.toInt());
  }
}

class KeyRow extends StatelessWidget {
  final List<SimpleKey> keys;

  KeyRow(this.keys);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: keys,
    );
  }
}

class SimpleKey extends StatelessWidget {
  final String char;
  final Function(String) onPressed;

  SimpleKey(this.char, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        child: Container(
          height: 60,
          child: Center(
              child: Text(
            char,
            style: TextStyle(fontSize: 18),
          )),
        ),
        onTap: () {
          onPressed(char);
        },
      ),
    );
  }
}
