import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/enums.dart';

/// Stores a set of [TriggerTag]s as a comma-joined list of enum names.
class TriggerTagSetConverter extends TypeConverter<Set<TriggerTag>, String> {
  const TriggerTagSetConverter();

  @override
  Set<TriggerTag> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const {};
    return fromDb
        .split(',')
        .map((name) => TriggerTag.values.asNameMap()[name])
        .whereType<TriggerTag>()
        .toSet();
  }

  @override
  String toSql(Set<TriggerTag> value) =>
      (value.map((t) => t.name).toList()..sort()).join(',');
}

/// Stores a set of [SymptomType]s as a comma-joined list of enum names.
class SymptomTypeSetConverter extends TypeConverter<Set<SymptomType>, String> {
  const SymptomTypeSetConverter();

  @override
  Set<SymptomType> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const {};
    return fromDb
        .split(',')
        .map((name) => SymptomType.values.asNameMap()[name])
        .whereType<SymptomType>()
        .toSet();
  }

  @override
  String toSql(Set<SymptomType> value) =>
      (value.map((t) => t.name).toList()..sort()).join(',');
}

/// Stores free-form coincident-factor tags (party, travel, deadline...) as a
/// JSON array so commas inside a tag can't corrupt the row.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return const [];
    return (jsonDecode(fromDb) as List).cast<String>();
  }

  @override
  String toSql(List<String> value) => value.isEmpty ? '' : jsonEncode(value);
}
