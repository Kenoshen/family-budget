import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budget/envelope/editEnvelope.dart';
import 'package:family_budget/keypad/keypad.dart';
import 'package:family_budget/model/currency.dart';
import 'package:family_budget/model/envelope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CollectionReference envelopeCollection =
        FirebaseFirestore.instance.collection("envelope");

    return StreamBuilder<QuerySnapshot>(
      stream: envelopeCollection.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        Widget? body;
        if (snapshot.hasError) {
          body = Text("${snapshot.error}");
        } else if (snapshot.hasData) {
          final docs = snapshot.data?.docs;
          if (docs != null) {
            body = ListView.builder(
                itemCount: docs.length,
                itemBuilder: (ctx, index) {
                  return EnvelopeItem(Envelope.fromSnapshot(docs[index]));
                });
          }
        } else {
          body = Text("Loading Data...");
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Envelopes"),
            actions: [
              IconButton(
                  onPressed: () => addEnvelope(context, envelopeCollection),
                  icon: Icon(Icons.add))
            ],
          ),
          body: body,
        );
      },
    );
  }

  addEnvelope(
      BuildContext context, CollectionReference envelopeCollection) async {
    final envelope = Envelope();
    final ref = await envelopeCollection.add(envelope.toJson());
    envelope.ref = ref;
    final result = await showEditEnvelope(context, envelope: envelope);
    if (result != null) {
      await result.ref?.set(result.toJson());
    }
  }
}

class EnvelopeItem extends StatefulWidget {
  final Envelope envelope;

  EnvelopeItem(this.envelope);

  @override
  _EnvelopeItemState createState() => _EnvelopeItemState();
}

class _EnvelopeItemState extends State<EnvelopeItem> {
  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 20);
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          height: 80,
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
        ),
      ),
      onTap: () => addAmount(context),
      onDoubleTap: () => editEnvelope(context),
      onLongPress: () => editEnvelope(context),
    );
  }

  addAmount(BuildContext context) async {
    final result = await showKeypad(context,
        title: widget.envelope.name,
        subtitle: "Total: ${amountToDollars(widget.envelope.amount)}");
    if (result != null) {
      widget.envelope.amount += (result * 100).toInt();
      await widget.envelope.ref?.set(widget.envelope.toJson());
    }
  }

  editEnvelope(BuildContext context) async {
    final result =
        await showEditEnvelope(context, envelope: widget.envelope.copy());
    if (result != null) {
      await result.ref?.set(result.toJson());
    }
  }
}
