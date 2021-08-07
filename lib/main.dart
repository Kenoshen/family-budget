import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dashboard/dashboard.dart';

void main() {
  debugPaintSizeEnabled = false;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else if (snapshot.connectionState == ConnectionState.done) {
            return FutureBuilder<UserCredential>(
              future: FirebaseAuth.instance.signInAnonymously(),
              builder: (ctx, snapshot) {
                if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Dashboard();
                } else {
                  return Text("Loading User...");
                }
              },
            );
          } else {
            return Text("Loading App...");
          }
        },
      ),
    );
  }
}
