import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'docRefJson.dart';

part "userExt.g.dart";

@JsonSerializable()
class UserExt {
  @JsonKey(ignore: true)
  DocumentReference ?ref;

  @JsonKey(ignore: true)
  String get id {
    return ref?.id ?? "";
  }

  String name;
  @JsonKey(fromJson: firestoreDocRefFromJson, toJson: firestoreDocRefToJson)
  DocumentReference<Map<String, dynamic>>? family;
  @JsonKey(fromJson: firestoreColRefFromJson, toJson: firestoreColRefToJson)
  CollectionReference<Map<String, dynamic>>? envelopes;

  UserExt({this.name = "", this.family, this.envelopes});

  factory UserExt.fromJson(Map<String, dynamic> json) => _$UserExtFromJson(json);
  Map<String, dynamic> toJson() => _$UserExtToJson(this);

  factory UserExt.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final e = UserExt.fromJson(doc.data()!);
    e.ref = doc.reference;
    return e;
  }
}