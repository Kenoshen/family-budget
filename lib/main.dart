import 'package:family_budgeter/display/displayError.dart';
import 'package:family_budgeter/user/withSignedInUser.dart';
import 'package:family_budgeter/user/withUserExt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dashboard/dashboard.dart';
import 'display/displayLoading.dart';
import 'preferences/preferences.dart';

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
      title: 'Family Budgeter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return DisplayError(snapshot.error);
          } else if (snapshot.connectionState == ConnectionState.done) {
            return WithSignedInUser(builder: (_, __) {
              return WithUserExt(builder: (_, __) {
                return Dashboard();
              });
            });
          } else {
            return DisplayLoading("Loading App...");
          }
        },
      ),
    );
  }

  Future<void> init() async {
    await _initialization;
    await Preferences.init();
  }
}
