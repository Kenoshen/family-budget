import 'package:json_annotation/json_annotation.dart';

part "activity.g.dart";

@JsonSerializable()
class Activity {
  int amt;
  String desc;
  DateTime? on;

  Activity({required this.desc, required this.amt, this.on}){
    if (on == null) {
      on = DateTime.now();
    }
  }

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  Activity copy() {
    return Activity.fromJson(toJson());
  }
}