import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:json_annotation/json_annotation.dart';

part "config.g.dart";

@JsonSerializable()
class Config {
  @JsonKey(name: "max_activity_length")
  int maxActivityLength;

  Config({required this.maxActivityLength});

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigToJson(this);

  Config copy() {
    return Config.fromJson(toJson());
  }

  static Future<bool> init() {
    return RemoteConfig.instance.fetchAndActivate();
  }

  static setDefaults(Config config) {
    RemoteConfig.instance.setDefaults(config.toJson());
  }

  static int getMaxActivityLength() {
    return RemoteConfig.instance.getInt("max_activity_length");
  }
}