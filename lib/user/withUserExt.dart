import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/display/displayError.dart';
import 'package:family_budgeter/display/displayLoading.dart';
import 'package:family_budgeter/model/userExt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

UserExt? currentUserExt;
User? currentUser;

class WithUserExt extends StatelessWidget {
  final Widget Function(BuildContext context, UserExt user) builder;

  WithUserExt({required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserExt>(
      future: getUser(),
        builder: (context, snapshot) {
      if (snapshot.hasError) {
        return DisplayError(snapshot.error);
      }
      if (snapshot.hasData) {
        final data = snapshot.data;
        if (data == null) {
          return DisplayError("data was null");
        }
        return builder(context, data);
      }
      return DisplayLoading("Loading user...");
    });
  }


  Future<UserExt> getUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw "could not find current user";
    }

    final snapshot = await FirebaseFirestore.instance.doc("userExt/${currentUser!.uid}").get();
    if (snapshot.exists) {
      currentUserExt = UserExt.fromSnapshot(snapshot);
      return currentUserExt!;
    }
    currentUserExt = UserExt();
    final refCreated = FirebaseFirestore.instance.collection("userExt").doc(currentUser!.uid);
    await refCreated.set(currentUserExt!.toJson());
    currentUserExt!.ref = refCreated;
    return currentUserExt!;
  }
}