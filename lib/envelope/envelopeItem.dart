import 'package:family_budgeter/keypad/keypad.dart';
import 'package:family_budgeter/model/activity.dart';
import 'package:family_budgeter/model/config.dart';
import 'package:family_budgeter/model/currency.dart';
import 'package:family_budgeter/model/envelope.dart';
import 'package:family_budgeter/user/withUserExt.dart';
import 'package:flutter/material.dart';

import 'editEnvelope.dart';

class EnvelopeItem extends StatefulWidget {
  final Envelope envelope;

  EnvelopeItem(Key key, this.envelope) : super(key: key);

  @override
  _EnvelopeItemState createState() => _EnvelopeItemState();
}

class _EnvelopeItemState extends State<EnvelopeItem> {
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 20);
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        height: 80,
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.envelope.name,
                  style: textStyle,
                ),
                Text(
                  "${amountToDollars(widget.envelope.amount)}",
                  style: textStyle,
                )
              ],
            ),
          ),
          onTap: () => addAmount(context),
          onDoubleTap: () => editEnvelope(context),
        ),
      ),
    );
  }

  addAmount(BuildContext context) async {
    final result = await showKeypad(context,
        title: widget.envelope.name,
        subtitle: "Total: ${amountToDollars(widget.envelope.amount)}");
    if (result != null) {
      final amt = (result * 100).toInt();
      if (amt != 0) {
        var name = currentUserExt?.name ?? "";
        widget.envelope.amount += amt;
        widget.envelope.addActivity(Activity(
            desc: [name, amt > 0 ? "add" : "subtract"]
                .where((s) => s.isNotEmpty)
                .join(" "),
            amt: amt));
        widget.envelope.trimActivity(Config.getMaxActivityLength());
        await widget.envelope.ref?.set(widget.envelope.toJson());
      }
    }
  }

  editEnvelope(BuildContext context) async {
    final result =
        await showEditEnvelope(context, envelope: widget.envelope.copy());
    if (result != null) {
      if (widget.envelope.amount != result.amount) {
        var name = currentUserExt?.name ?? "";
        result.addActivity(Activity(
            desc: [name, "set"].where((s) => s.isNotEmpty).join(" "),
            amt: result.amount));
      }
      await result.ref?.set(result.toJson());
    }
  }
}
