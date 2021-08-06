// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Envelope _$EnvelopeFromJson(Map<String, dynamic> json) {
  return Envelope(
    name: json['name'] as String,
    amount: json['amount'] as int,
    refillAmount: json['refillAmount'] as int,
    refillEvery: _$enumDecode(_$RefillEveryEnumMap, json['refillEvery']),
    allowOverfill: json['allowOverfill'] as bool,
  );
}

Map<String, dynamic> _$EnvelopeToJson(Envelope instance) => <String, dynamic>{
      'amount': instance.amount,
      'name': instance.name,
      'refillAmount': instance.refillAmount,
      'refillEvery': _$RefillEveryEnumMap[instance.refillEvery],
      'allowOverfill': instance.allowOverfill,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$RefillEveryEnumMap = {
  RefillEvery.day: 'day',
  RefillEvery.week: 'week',
  RefillEvery.month: 'month',
  RefillEvery.year: 'year',
};
