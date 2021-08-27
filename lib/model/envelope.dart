import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_budgeter/model/activity.dart';
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
  List<Activity>? activity;

  Envelope({this.name = "", this.amount = 0, this.refillAmount = 0, this.refillEvery = RefillEvery.week, this.allowOverfill = false, this.activity});

  factory Envelope.fromJson(Map<String, dynamic> json) => _$EnvelopeFromJson(json);
  Map<String, dynamic> toJson() {
    var json = _$EnvelopeToJson(this);
    if (activity != null) {
      json["activity"] = activity!.map((e) => e.toJson()).toList();
    }
    return json;
  }

  factory Envelope.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final e = Envelope.fromJson(doc.data());
    e.ref = doc.reference;
    return e;
  }

  Envelope copy() {
    final e = Envelope.fromJson(toJson());
    e.ref = ref;
    return e;
  }

  Envelope addActivity(Activity a) {
    if (activity == null) {
      activity = [];
    }
    activity!.add(a);
    return this;
  }

  Envelope trimActivity(int maxLength) {
    if (activity != null && activity!.length > maxLength) {
      activity!.removeRange(0, activity!.length - maxLength);
    }
    return this;
  }
}