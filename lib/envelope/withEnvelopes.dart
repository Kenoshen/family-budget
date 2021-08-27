import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/display/displayError.dart';
import 'package:family_budgeter/display/displayLoading.dart';
import 'package:family_budgeter/envelope/envelopeSourceNotifier.dart';
import 'package:family_budgeter/model/envelope.dart';
import 'package:family_budgeter/model/userExt.dart';
import 'package:family_budgeter/user/withUserExt.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

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
    return FutureBuilder<CollectionReference<Map<String, dynamic>>?>(
      future: envelopeCollection(context),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DisplayError(snapshot.error);
        }
        if (snapshot.hasData && snapshot.data != null) {
          final envelopeCollectionRef = snapshot.data;
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: envelopeCollectionRef!.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return DisplayError(snapshot.error);
              }
              if (snapshot.hasData && snapshot.data != null) {
                final envelopes = snapshot.data!.docs
                    .map((doc) => Envelope.fromSnapshot(doc))
                    .toList();
                return builder(context, envelopes, envelopeCollectionRef);
              }
              return DisplayLoading("Loading envelope data...");
            },
          );
        }
        return DisplayLoading("Loading envelopes...");
      },
    );
  }

  Future<CollectionReference<Map<String, dynamic>>?> envelopeCollection(BuildContext context) async {
    final source = context.watch<EnvelopeSourceNotifier>();
    if (source.source != null) {
      return source.source!;
    } else {
      return await source.calculateEnvelopeCollection();
    }
  }
}
