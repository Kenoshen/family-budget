import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/debug/debug.dart';
import 'package:family_budgeter/envelope/envelopeSourceNotifier.dart';
import 'package:family_budgeter/envelope/share.dart';
import 'package:family_budgeter/envelope/withEnvelopes.dart';
import 'package:family_budgeter/model/activity.dart';
import 'package:family_budgeter/model/config.dart';
import 'package:family_budgeter/model/family.dart';
import 'package:family_budgeter/model/userExt.dart';
import 'package:family_budgeter/user/withUserExt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
            //title: Text((currentUserExt?.family != null ? "Family " : "") + "Envelopes"),
              title: Text("${currentUserExt?.id}"),
            actions: [
              IconButton(
                  onPressed: () => addEnvelope(context, envelopeCollection),
                  icon: Icon(Icons.add)),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: <Widget?>[
                DrawerHeader(child: Text("Family Budgeter")),
                ListTile(
                  title: Text("Share Envelopes"),
                  leading: Icon(Icons.person_add),
                  onTap: () => addToFamily(context),
                ),
                currentUserExt?.family != null
                    ? ListTile(
                        title: Text("Stop Sharing"),
                        leading: Icon(Icons.person_remove),
                        onTap: () => leaveFamily(context),
                      )
                    : null,
                ListTile(
                  title: Text("Debug"),
                  leading: Icon(Icons.bug_report_outlined),
                  onTap: () => showDebug(context),
                ),
              ].where((e) => e != null).map((e) => e!).toList(),
            ),
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
                  child: Text(
                    "Add a new envelope by pressing the + button",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30, color: Theme.of(context).disabledColor),
                  ),
                ),
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

  addToFamily(BuildContext context) async {
    final UserExt? u = currentUserExt;
    if (u != null) {
      Family family;
      var newFamily = false;
      if (u.family == null) {
        newFamily = true;
        family = Family();
        final col = FirebaseFirestore.instance.collection("family");
        final ref = await col.add(family.toJson());
        family.ref = ref;
        u.family = FirebaseFirestore.instance.doc("family/${family.id}");
        await u.ref!.set({"family": u.family});
      } else {
        family = Family.fromSnapshot(await u.family!.get());
      }

      if (newFamily) {
        // grab all of the envelopes from the user and copy them to the family envelopes
        final ref = await u.envelopes.get();
        final envelopes =
            ref.docs.map((d) => Envelope.fromSnapshot(d)).toList();
        if (envelopes.isNotEmpty) {
          await Future.wait(
              envelopes.map((e) => family.envelopes.add(e.toJson())));
        }
      }

      // set the envelope source on the provider
      Provider.of<EnvelopeSourceNotifier>(context, listen: false).source =
          family.envelopes;

      final String shareLink = await inviteToFamily(family);
      Share.share("Share my Family Budgeter envelopes: $shareLink");
    }
  }

  leaveFamily(BuildContext context) async {
    final UserExt? u = currentUserExt;
    if (u != null) {
      if (u.family != null) {
        u.family = null;
        await u.ref!.set({"family": null});
        Provider.of<EnvelopeSourceNotifier>(context, listen: false).source =
            u.envelopes;
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
        widget.envelope.amount += amt;
        widget.envelope.addActivity(
            Activity(desc: amt > 0 ? "add" : "subtract", amt: amt));
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
        result.addActivity(Activity(desc: "set amount", amt: result.amount));
      }
      await result.ref?.set(result.toJson());
    }
  }
}
