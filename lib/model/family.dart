import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part "family.g.dart";

@JsonSerializable()
class Family {
  @JsonKey(ignore: true)
  DocumentReference ?ref;

  @JsonKey(ignore: true)
  String get id {
    return ref?.id ?? "";
  }

  final String name;

  @JsonKey(ignore: true)
  CollectionReference<Map<String, dynamic>>? _envelopes;
  @JsonKey(ignore: true)
  CollectionReference<Map<String, dynamic>> get envelopes {
    if (_envelopes == null) {
      _envelopes = FirebaseFirestore.instance.collection("family/$id/envelopes");
    }
    return _envelopes!;
  }

  Family({this.name = ""});

  factory Family.fromJson(Map<String, dynamic> json) => _$FamilyFromJson(json);
  Map<String, dynamic> toJson() => _$FamilyToJson(this);

  factory Family.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final e = Family.fromJson(doc.data()!);
    e.ref = doc.reference;
    return e;
  }
}