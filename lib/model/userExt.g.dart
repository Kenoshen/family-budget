// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'userExt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserExt _$UserExtFromJson(Map<String, dynamic> json) {
  return UserExt(
    name: json['name'] as String?,
    family: firestoreDocRefFromJson(json['family']),
    envelopes: firestoreColRefFromJson(json['envelopes']),
  );
}

Map<String, dynamic> _$UserExtToJson(UserExt instance) => <String, dynamic>{
      'name': instance.name,
      'family': firestoreDocRefToJson(instance.family),
      'envelopes': firestoreColRefToJson(instance.envelopes),
    };
