import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/model/userExt.dart';
import 'package:family_budgeter/user/withUserExt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

Future<void> showDebug(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => Debug()),
  );
}

class Debug extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Debug"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Set Family"),
            leading: Icon(Icons.people),
            onTap: () => setFamily(context),
          ),
          ListTile(
            title: Text("Set Name"),
            leading: Icon(Icons.account_box),
            onTap: () => setName(context),
          )
        ],
      ),
    );
  }

  setFamily(BuildContext context) async {
    if (currentUserExt != null) {
      UserExt u = currentUserExt!;
      var familyId = "";

      if (u.family != null) {
        familyId = u.family!.id;
      }
      String? newFamilyId = await prompt(context,
          title: Text("Set Family"), initialValue: familyId);
      if (newFamilyId != null) {
        u.family = FirebaseFirestore.instance.doc("family/$newFamilyId");
        await u.ref!.update({"family": u.family});
      }
    }
  }

  setName(BuildContext context) async {
    if (currentUserExt != null) {
      UserExt u = currentUserExt!;
      var name = u.name;
      String? newName = await prompt(context,
          title: Text("Set Name"), initialValue: name);
      if (newName != null) {
        u.name = newName;
        await u.ref!.update({"name": u.name});
      }
    }
  }
}
