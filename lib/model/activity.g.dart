// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) {
  return Activity(
    desc: json['desc'] as String,
    amt: json['amt'] as int,
    on: json['on'] == null ? null : DateTime.parse(json['on'] as String),
  );
}

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'amt': instance.amt,
      'desc': instance.desc,
      'on': instance.on?.toIso8601String(),
    };
