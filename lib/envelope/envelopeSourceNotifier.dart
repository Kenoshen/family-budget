import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/model/family.dart';
import 'package:family_budgeter/model/userExt.dart';
import 'package:family_budgeter/user/withUserExt.dart';
import 'package:flutter/foundation.dart';

class EnvelopeSourceNotifier with ChangeNotifier {
  CollectionReference<Map<String, dynamic>>? _source;

  CollectionReference<Map<String, dynamic>>? get source => _source;

  set source(CollectionReference<Map<String, dynamic>>? value) {
    _source = value;
    notifyListeners();
  }

  Future<CollectionReference<Map<String, dynamic>>?>
      calculateEnvelopeCollection() async {
    UserExt? u = currentUserExt;
    if (u != null) {
      if (u.family != null) {
        final familySnapshot = await u.family!.get();
        if (familySnapshot.exists) {
          final family = Family.fromSnapshot(familySnapshot);
          if (family.envelopes == null) {
            family.envelopes = FirebaseFirestore.instance
                .collection("family/${familySnapshot.id}/envelopes");
          }
          _source = family.envelopes!;
        }
      }
      if (u.envelopes == null) {
        u.envelopes =
            FirebaseFirestore.instance.collection("userExt/${u.id}/envelopes");
      }
      _source = u.envelopes!;
    }
    return source;
  }
}
