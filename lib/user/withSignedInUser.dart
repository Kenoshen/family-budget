import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/model/userExt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class WithSignedInUser extends StatelessWidget {
  final Widget Function(BuildContext context, User user) builder;

  WithSignedInUser({required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserCredential>(
      future: FirebaseAuth.instance.signInAnonymously(),
        builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text("${snapshot.error}");
      }
      if (snapshot.hasData) {
        final data = snapshot.data;
        if (data == null || data.user == null) {
          return Text("user data was null");
        }
        return builder(context, data.user!);
      }
      return Text("Loading user...");
    });
  }
}