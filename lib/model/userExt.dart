import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'docRefJson.dart';

part "userExt.g.dart";

@JsonSerializable()
class UserExt {
  @JsonKey(ignore: true)
  DocumentReference? ref;

  @JsonKey(ignore: true)
  String get id {
    return ref?.id ?? "";
  }

  String? name;
  @JsonKey(fromJson: firestoreDocRefFromJson, toJson: firestoreDocRefToJson)
  DocumentReference<Map<String, dynamic>>? family;

  @JsonKey(ignore: true)
  CollectionReference<Map<String, dynamic>>? _envelopes;
  @JsonKey(ignore: true)
  CollectionReference<Map<String, dynamic>> get envelopes {
    if (_envelopes == null) {
      _envelopes = FirebaseFirestore.instance.collection("userExt/$id/envelopes");
    }
    return _envelopes!;
  }

  UserExt({this.name = "", this.family});

  factory UserExt.fromJson(Map<String, dynamic> json) => _$UserExtFromJson(json);
  Map<String, dynamic> toJson() => _$UserExtToJson(this);

  factory UserExt.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final e = UserExt.fromJson(doc.data()!);
    e.ref = doc.reference;
    return e;
  }
}