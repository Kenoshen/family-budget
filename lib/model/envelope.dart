import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part "envelope.g.dart";

enum RefillEvery {day, week, month, year}

@JsonSerializable()
class Envelope {
  @JsonKey(ignore: true)
  DocumentReference ?ref;

  @JsonKey(ignore: true)
  String get id {
    return ref?.id ?? "";
  }

  int amount;
  String name;
  int refillAmount;
  RefillEvery refillEvery;
  bool allowOverfill;

  Envelope({this.name = "", this.amount = 0, this.refillAmount = 0, this.refillEvery = RefillEvery.week, this.allowOverfill = false});

  factory Envelope.fromJson(Map<String, dynamic> json) => _$EnvelopeFromJson(json);
  Map<String, dynamic> toJson() => _$EnvelopeToJson(this);

  factory Envelope.fromSnapshot(QueryDocumentSnapshot doc) {
    final e = Envelope.fromJson(doc.data() as Map<String, dynamic>);
    e.ref = doc.reference;
    return e;
  }

  Envelope copy() {
    final e = Envelope.fromJson(toJson());
    e.ref = ref;
    return e;
  }
}