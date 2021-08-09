import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/model/envelope.dart';
import 'package:json_annotation/json_annotation.dart';

import 'docRefJson.dart';

part "family.g.dart";

@JsonSerializable()
class Family {
  @JsonKey(ignore: true)
  DocumentReference ?ref;

  @JsonKey(ignore: true)
  String get id {
    return ref?.id ?? "";
  }

  @JsonKey(fromJson: firestoreColRefFromJson, toJson: firestoreColRefToJson)
  CollectionReference<Map<String, dynamic>>? envelopes;

  Family({this.envelopes});

  factory Family.fromJson(Map<String, dynamic> json) => _$FamilyFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyToJson(this);

  factory Family.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final e = Family.fromJson(doc.data()!);
    e.ref = doc.reference;
    return e;
  }
}