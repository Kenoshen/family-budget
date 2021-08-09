import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/model/envelope.dart';
import 'package:family_budgeter/model/family.dart';
import 'package:family_budgeter/model/userExt.dart';
import 'package:family_budgeter/user/withUserExt.dart';
import 'package:flutter/cupertino.dart';

class WithEnvelopes extends StatelessWidget {
  final Widget Function(BuildContext context, List<Envelope> envelopes,
      CollectionReference<Map<String, dynamic>> envelopesCollection) builder;

  WithEnvelopes({required this.builder});

  @override
  Widget build(BuildContext context) {
    final UserExt? u = currentUserExt;
    if (u == null) {
      return Container();
    }
    return FutureBuilder<CollectionReference<Map<String, dynamic>>>(
      future: envelopeCollection(u),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        if (snapshot.hasData && snapshot.data != null) {
          final envelopeCollectionRef = snapshot.data;
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: envelopeCollectionRef!.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              if (snapshot.hasData && snapshot.data != null) {
                final envelopes = snapshot.data!.docs
                    .map((doc) => Envelope.fromSnapshot(doc))
                    .toList();
                return builder(context, envelopes, envelopeCollectionRef);
              }
              return Text("Loading envelope data...");
            },
          );
        }
        return Text("Loading envelopes...");
      },
    );
  }

  Future<CollectionReference<Map<String, dynamic>>> envelopeCollection(
      UserExt u) async {
    if (u.family != null) {
      final familySnapshot = await u.family!.get();
      if (familySnapshot.exists) {
        final family = Family.fromSnapshot(familySnapshot);
        if (family.envelopes == null) {
          family.envelopes = FirebaseFirestore.instance
              .collection("family/${familySnapshot.id}/envelopes");
        }
        return family.envelopes!;
      }
    }
    if (u.envelopes == null) {
      u.envelopes = FirebaseFirestore.instance
          .collection("userExt/${u.id}/envelopes");
    }
    return u.envelopes!;
  }
}
