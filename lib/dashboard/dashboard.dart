import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/envelope/withEnvelopes.dart';
import 'package:family_budgeter/model/family.dart';
import 'package:family_budgeter/model/userExt.dart';
import 'package:family_budgeter/user/withUserExt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../envelope/editEnvelope.dart';
import '../keypad/keypad.dart';
import '../model/currency.dart';
import '../model/envelope.dart';
import '../preferences/preferences.dart';

class Dashboard extends StatelessWidget {
  final GlobalKey _reorderListKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WithEnvelopes(
      builder: (BuildContext context, List<Envelope> envelopes,
          CollectionReference<Map<String, dynamic>> envelopeCollection) {
        final docs = [...envelopes];
        final sortOrder = Preferences.sortOrder();
        var dirtySortOrder = false;
        List<String> oldEntries = [...sortOrder];
        docs.forEach((doc) {
          if (sortOrder.indexOf(doc.id) < 0) {
            sortOrder.add(doc.id);
            dirtySortOrder = true;
          } else {
            oldEntries.remove(doc.id);
          }
        });
        if (dirtySortOrder || oldEntries.isNotEmpty) {
          oldEntries.forEach((old) => sortOrder.remove(old));
          Preferences.setSortOrder(sortOrder);
        }
        docs.sort((a, b) => sortOrder.indexOf(a.id) - sortOrder.indexOf(b.id));

        return Scaffold(
          appBar: AppBar(
            title: Text("Envelopes"),
            leading: IconButton(
                onPressed: () => addToFamily(context),
                icon: Icon(Icons.person_add)),
            actions: [
              IconButton(
                  onPressed: () => leaveFamily(context),
                  icon: Icon(Icons.person_remove)),
              IconButton(
                  onPressed: () => addEnvelope(context, envelopeCollection),
                  icon: Icon(Icons.add)),
            ],
          ),
          body: docs.isNotEmpty
              ? ReorderableListView.builder(
            key: _reorderListKey,
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              var doc = docs[index];
              return EnvelopeItem(ValueKey(doc.id), doc);
            },
            onReorder: (int oldIndex, int newIndex) {
              var id = sortOrder.removeAt(oldIndex);
              if (newIndex > oldIndex) {
                sortOrder.insert(newIndex - 1, id);
              } else {
                sortOrder.insert(newIndex, id);
              }
              docs.sort((a, b) =>
              sortOrder.indexOf(a.id) - sortOrder.indexOf(b.id));
              Preferences.setSortOrder(sortOrder);
            },
          )
              : Padding(
            padding: EdgeInsets.all(40),
            child: Text("Add a new envelope by pressing the + button",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 30, color: Theme.of(context).disabledColor),),
          ),
        );
      },
    );
  }

  addEnvelope(BuildContext context,
      CollectionReference envelopeCollection) async {
    final envelope = Envelope();
    final ref = await envelopeCollection.add(envelope.toJson());
    envelope.ref = ref;
    final result = await showEditEnvelope(context, envelope: envelope);
    if (result != null) {
      await result.ref?.set(result.toJson());
    }
  }

  addToFamily(BuildContext context) async {
    print("Add to family");
    final UserExt? u = currentUserExt;
    if (u != null) {
      Family family;
      if (u.family == null) {
        family = Family();
        final col = FirebaseFirestore.instance.collection("family");
        final ref = await col.add(family.toJson());
        family.ref = ref;
        u.family = FirebaseFirestore.instance.doc("family/${family.id}");
        await u.ref!.set({"family": u.family});
      } else {
        family = Family.fromSnapshot(await u.family!.get());
      }

      if (u.envelopes != null) {
        print("add to family envelopes");
        family.envelopes = FirebaseFirestore.instance.collection("family/${family.id}/envelopes");
        final ref = await u.envelopes!.get();
        print("Get user envelopes ref ${ref.size}");
        final envelopes = ref.docs.map((d) => Envelope.fromSnapshot(d)).toList();
        print("Got envelopes: ${envelopes.length}");
        await Future.wait(envelopes.map((e) => family.envelopes!.add(e.toJson())));
        // TODO: need to figure out how to switch over the envelopes collection that the WithEnvelopes.steam is looking at
      }
    }
  }

  leaveFamily(BuildContext context) async {
    print("Leave family");
    final UserExt? u = currentUserExt;
    if (u != null) {
      if (u.family != null) {
        u.family = null;
        await u.ref!.set({"family": null});
      }
    }
  }
}

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
