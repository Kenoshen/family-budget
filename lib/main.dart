import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/display/displayError.dart';
import 'package:family_budgeter/envelope/envelopeSourceNotifier.dart';
import 'package:family_budgeter/user/withSignedInUser.dart';
import 'package:family_budgeter/user/withUserExt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'dashboard/dashboard.dart';
import 'display/displayLoading.dart';
import 'model/userExt.dart';
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
              return WithUserExt(builder: (context, __) {
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: (_) => EnvelopeSourceNotifier()),
                  ],
                  child: FutureBuilder(
                    future: initDynamicLinks(context),
                    // must be after login and providers
                    builder: (context, _) {
                      return Dashboard();
                    },
                  ),
                );
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

  Future<void> initDynamicLinks(BuildContext context) async {
    final setFamily = (UserExt u, Uri deepLink) async {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Set family"),
              content: Text("${u.id} $deepLink"),
            );
          });
      final familyId = deepLink.queryParameters["family"];
      print("Set family: $familyId}");
      u.family = FirebaseFirestore.instance.doc("family/$familyId");
      await u.ref!.set({"family": u.family});
      final source =
          Provider.of<EnvelopeSourceNotifier>(context, listen: false);
      source.source = await source
          .calculateEnvelopeCollection(); // notify listeners of change
    };

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;
      showDialog(context: context, builder: (ctx){
        return AlertDialog(title: Text("Got dynamic link"), content: Text("$deepLink"),);
      });
      print("Got dynamic link with open app: $dynamicLink $deepLink");
      final UserExt? u = currentUserExt;
      if (deepLink != null &&
          deepLink.queryParameters.containsKey("family") &&
          u != null) {
        setFamily(u, deepLink);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
      showDialog(context: context, builder: (ctx){
        return AlertDialog(title: Text("Got dynamic link error"), content: Text("$e"),);
      });
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    final UserExt? u = currentUserExt;
    if (deepLink != null) {
      showDialog(context: context, builder: (ctx){
        return AlertDialog(title: Text("Got initial deep link"), content: Text("$deepLink"),);
      });
      print("Got initial deep link: $deepLink");
      if (deepLink.queryParameters.containsKey("family") && u != null) {
        setFamily(u, deepLink);
      }
    }
  }
}
