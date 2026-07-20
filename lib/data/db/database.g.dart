// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MealsTable extends Meals with TableInfo<$MealsTable, Meal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PortionSize, String> portionSize =
      GeneratedColumn<String>(
        'portion_size',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PortionSize>($MealsTable.$converterportionSize);
  @override
  late final GeneratedColumnWithTypeConverter<MealSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MealSource>($MealsTable.$convertersource);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    photoPath,
    note,
    portionSize,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Meal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Meal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Meal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      portionSize: $MealsTable.$converterportionSize.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}portion_size'],
        )!,
      ),
      source: $MealsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
    );
  }

  @override
  $MealsTable createAlias(String alias) {
    return $MealsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PortionSize, String, String> $converterportionSize =
      const EnumNameConverter<PortionSize>(PortionSize.values);
  static JsonTypeConverter2<MealSource, String, String> $convertersource =
      const EnumNameConverter<MealSource>(MealSource.values);
}

class Meal extends DataClass implements Insertable<Meal> {
  final int id;
  final DateTime timestamp;
  final String? photoPath;
  final String? note;
  final PortionSize portionSize;
  final MealSource source;
  const Meal({
    required this.id,
    required this.timestamp,
    this.photoPath,
    this.note,
    required this.portionSize,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['portion_size'] = Variable<String>(
        $MealsTable.$converterportionSize.toSql(portionSize),
      );
    }
    {
      map['source'] = Variable<String>(
        $MealsTable.$convertersource.toSql(source),
      );
    }
    return map;
  }

  MealsCompanion toCompanion(bool nullToAbsent) {
    return MealsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      portionSize: Value(portionSize),
      source: Value(source),
    );
  }

  factory Meal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Meal(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      note: serializer.fromJson<String?>(json['note']),
      portionSize: $MealsTable.$converterportionSize.fromJson(
        serializer.fromJson<String>(json['portionSize']),
      ),
      source: $MealsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'photoPath': serializer.toJson<String?>(photoPath),
      'note': serializer.toJson<String?>(note),
      'portionSize': serializer.toJson<String>(
        $MealsTable.$converterportionSize.toJson(portionSize),
      ),
      'source': serializer.toJson<String>(
        $MealsTable.$convertersource.toJson(source),
      ),
    };
  }

  Meal copyWith({
    int? id,
    DateTime? timestamp,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> note = const Value.absent(),
    PortionSize? portionSize,
    MealSource? source,
  }) => Meal(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    note: note.present ? note.value : this.note,
    portionSize: portionSize ?? this.portionSize,
    source: source ?? this.source,
  );
  Meal copyWithCompanion(MealsCompanion data) {
    return Meal(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      note: data.note.present ? data.note.value : this.note,
      portionSize: data.portionSize.present
          ? data.portionSize.value
          : this.portionSize,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Meal(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('photoPath: $photoPath, ')
          ..write('note: $note, ')
          ..write('portionSize: $portionSize, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, timestamp, photoPath, note, portionSize, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Meal &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.photoPath == this.photoPath &&
          other.note == this.note &&
          other.portionSize == this.portionSize &&
          other.source == this.source);
}

class MealsCompanion extends UpdateCompanion<Meal> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<String?> photoPath;
  final Value<String?> note;
  final Value<PortionSize> portionSize;
  final Value<MealSource> source;
  const MealsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.note = const Value.absent(),
    this.portionSize = const Value.absent(),
    this.source = const Value.absent(),
  });
  MealsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    this.photoPath = const Value.absent(),
    this.note = const Value.absent(),
    required PortionSize portionSize,
    required MealSource source,
  }) : timestamp = Value(timestamp),
       portionSize = Value(portionSize),
       source = Value(source);
  static Insertable<Meal> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? photoPath,
    Expression<String>? note,
    Expression<String>? portionSize,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (photoPath != null) 'photo_path': photoPath,
      if (note != null) 'note': note,
      if (portionSize != null) 'portion_size': portionSize,
      if (source != null) 'source': source,
    });
  }

  MealsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<String?>? photoPath,
    Value<String?>? note,
    Value<PortionSize>? portionSize,
    Value<MealSource>? source,
  }) {
    return MealsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      photoPath: photoPath ?? this.photoPath,
      note: note ?? this.note,
      portionSize: portionSize ?? this.portionSize,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (portionSize.present) {
      map['portion_size'] = Variable<String>(
        $MealsTable.$converterportionSize.toSql(portionSize.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $MealsTable.$convertersource.toSql(source.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('photoPath: $photoPath, ')
          ..write('note: $note, ')
          ..write('portionSize: $portionSize, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _canonicalNameMeta = const VerificationMeta(
    'canonicalName',
  );
  @override
  late final GeneratedColumn<String> canonicalName = GeneratedColumn<String>(
    'canonical_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Set<TriggerTag>, String>
  triggerTags = GeneratedColumn<String>(
    'trigger_tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  ).withConverter<Set<TriggerTag>>($IngredientsTable.$convertertriggerTags);
  @override
  List<GeneratedColumn> get $columns => [id, canonicalName, triggerTags];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ingredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('canonical_name')) {
      context.handle(
        _canonicalNameMeta,
        canonicalName.isAcceptableOrUnknown(
          data['canonical_name']!,
          _canonicalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      canonicalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_name'],
      )!,
      triggerTags: $IngredientsTable.$convertertriggerTags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trigger_tags'],
        )!,
      ),
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }

  static TypeConverter<Set<TriggerTag>, String> $convertertriggerTags =
      const TriggerTagSetConverter();
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final int id;
  final String canonicalName;
  final Set<TriggerTag> triggerTags;
  const Ingredient({
    required this.id,
    required this.canonicalName,
    required this.triggerTags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['canonical_name'] = Variable<String>(canonicalName);
    {
      map['trigger_tags'] = Variable<String>(
        $IngredientsTable.$convertertriggerTags.toSql(triggerTags),
      );
    }
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      canonicalName: Value(canonicalName),
      triggerTags: Value(triggerTags),
    );
  }

  factory Ingredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<int>(json['id']),
      canonicalName: serializer.fromJson<String>(json['canonicalName']),
      triggerTags: serializer.fromJson<Set<TriggerTag>>(json['triggerTags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'canonicalName': serializer.toJson<String>(canonicalName),
      'triggerTags': serializer.toJson<Set<TriggerTag>>(triggerTags),
    };
  }

  Ingredient copyWith({
    int? id,
    String? canonicalName,
    Set<TriggerTag>? triggerTags,
  }) => Ingredient(
    id: id ?? this.id,
    canonicalName: canonicalName ?? this.canonicalName,
    triggerTags: triggerTags ?? this.triggerTags,
  );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      id: data.id.present ? data.id.value : this.id,
      canonicalName: data.canonicalName.present
          ? data.canonicalName.value
          : this.canonicalName,
      triggerTags: data.triggerTags.present
          ? data.triggerTags.value
          : this.triggerTags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('triggerTags: $triggerTags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, canonicalName, triggerTags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.canonicalName == this.canonicalName &&
          other.triggerTags == this.triggerTags);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<int> id;
  final Value<String> canonicalName;
  final Value<Set<TriggerTag>> triggerTags;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.canonicalName = const Value.absent(),
    this.triggerTags = const Value.absent(),
  });
  IngredientsCompanion.insert({
    this.id = const Value.absent(),
    required String canonicalName,
    this.triggerTags = const Value.absent(),
  }) : canonicalName = Value(canonicalName);
  static Insertable<Ingredient> custom({
    Expression<int>? id,
    Expression<String>? canonicalName,
    Expression<String>? triggerTags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (canonicalName != null) 'canonical_name': canonicalName,
      if (triggerTags != null) 'trigger_tags': triggerTags,
    });
  }

  IngredientsCompanion copyWith({
    Value<int>? id,
    Value<String>? canonicalName,
    Value<Set<TriggerTag>>? triggerTags,
  }) {
    return IngredientsCompanion(
      id: id ?? this.id,
      canonicalName: canonicalName ?? this.canonicalName,
      triggerTags: triggerTags ?? this.triggerTags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (canonicalName.present) {
      map['canonical_name'] = Variable<String>(canonicalName.value);
    }
    if (triggerTags.present) {
      map['trigger_tags'] = Variable<String>(
        $IngredientsTable.$convertertriggerTags.toSql(triggerTags.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('triggerTags: $triggerTags')
          ..write(')'))
        .toString();
  }
}

class $MealIngredientsTable extends MealIngredients
    with TableInfo<$MealIngredientsTable, MealIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<int> mealId = GeneratedColumn<int>(
    'meal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES meals (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
    'ingredient_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<IngredientConfidence, String>
  confidence =
      GeneratedColumn<String>(
        'confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<IngredientConfidence>(
        $MealIngredientsTable.$converterconfidence,
      );
  @override
  List<GeneratedColumn> get $columns => [mealId, ingredientId, confidence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_ingredients';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealIngredient> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meal_id')) {
      context.handle(
        _mealIdMeta,
        mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mealId, ingredientId};
  @override
  MealIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealIngredient(
      mealId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}meal_id'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ingredient_id'],
      )!,
      confidence: $MealIngredientsTable.$converterconfidence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}confidence'],
        )!,
      ),
    );
  }

  @override
  $MealIngredientsTable createAlias(String alias) {
    return $MealIngredientsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<IngredientConfidence, String, String>
  $converterconfidence = const EnumNameConverter<IngredientConfidence>(
    IngredientConfidence.values,
  );
}

class MealIngredient extends DataClass implements Insertable<MealIngredient> {
  final int mealId;
  final int ingredientId;
  final IngredientConfidence confidence;
  const MealIngredient({
    required this.mealId,
    required this.ingredientId,
    required this.confidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meal_id'] = Variable<int>(mealId);
    map['ingredient_id'] = Variable<int>(ingredientId);
    {
      map['confidence'] = Variable<String>(
        $MealIngredientsTable.$converterconfidence.toSql(confidence),
      );
    }
    return map;
  }

  MealIngredientsCompanion toCompanion(bool nullToAbsent) {
    return MealIngredientsCompanion(
      mealId: Value(mealId),
      ingredientId: Value(ingredientId),
      confidence: Value(confidence),
    );
  }

  factory MealIngredient.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealIngredient(
      mealId: serializer.fromJson<int>(json['mealId']),
      ingredientId: serializer.fromJson<int>(json['ingredientId']),
      confidence: $MealIngredientsTable.$converterconfidence.fromJson(
        serializer.fromJson<String>(json['confidence']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mealId': serializer.toJson<int>(mealId),
      'ingredientId': serializer.toJson<int>(ingredientId),
      'confidence': serializer.toJson<String>(
        $MealIngredientsTable.$converterconfidence.toJson(confidence),
      ),
    };
  }

  MealIngredient copyWith({
    int? mealId,
    int? ingredientId,
    IngredientConfidence? confidence,
  }) => MealIngredient(
    mealId: mealId ?? this.mealId,
    ingredientId: ingredientId ?? this.ingredientId,
    confidence: confidence ?? this.confidence,
  );
  MealIngredient copyWithCompanion(MealIngredientsCompanion data) {
    return MealIngredient(
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealIngredient(')
          ..write('mealId: $mealId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('confidence: $confidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mealId, ingredientId, confidence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealIngredient &&
          other.mealId == this.mealId &&
          other.ingredientId == this.ingredientId &&
          other.confidence == this.confidence);
}

class MealIngredientsCompanion extends UpdateCompanion<MealIngredient> {
  final Value<int> mealId;
  final Value<int> ingredientId;
  final Value<IngredientConfidence> confidence;
  final Value<int> rowid;
  const MealIngredientsCompanion({
    this.mealId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.confidence = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealIngredientsCompanion.insert({
    required int mealId,
    required int ingredientId,
    required IngredientConfidence confidence,
    this.rowid = const Value.absent(),
  }) : mealId = Value(mealId),
       ingredientId = Value(ingredientId),
       confidence = Value(confidence);
  static Insertable<MealIngredient> custom({
    Expression<int>? mealId,
    Expression<int>? ingredientId,
    Expression<String>? confidence,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mealId != null) 'meal_id': mealId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (confidence != null) 'confidence': confidence,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealIngredientsCompanion copyWith({
    Value<int>? mealId,
    Value<int>? ingredientId,
    Value<IngredientConfidence>? confidence,
    Value<int>? rowid,
  }) {
    return MealIngredientsCompanion(
      mealId: mealId ?? this.mealId,
      ingredientId: ingredientId ?? this.ingredientId,
      confidence: confidence ?? this.confidence,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mealId.present) {
      map['meal_id'] = Variable<int>(mealId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<String>(
        $MealIngredientsTable.$converterconfidence.toSql(confidence.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealIngredientsCompanion(')
          ..write('mealId: $mealId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('confidence: $confidence, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContextEntriesTable extends ContextEntries
    with TableInfo<$ContextEntriesTable, ContextEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContextEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ContextType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ContextType>($ContextEntriesTable.$convertertype);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, timestamp, type, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'context_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContextEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContextEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContextEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      type: $ContextEntriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $ContextEntriesTable createAlias(String alias) {
    return $ContextEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ContextType, String, String> $convertertype =
      const EnumNameConverter<ContextType>(ContextType.values);
}

class ContextEntry extends DataClass implements Insertable<ContextEntry> {
  final int id;
  final DateTime timestamp;
  final ContextType type;
  final double value;
  const ContextEntry({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    {
      map['type'] = Variable<String>(
        $ContextEntriesTable.$convertertype.toSql(type),
      );
    }
    map['value'] = Variable<double>(value);
    return map;
  }

  ContextEntriesCompanion toCompanion(bool nullToAbsent) {
    return ContextEntriesCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      type: Value(type),
      value: Value(value),
    );
  }

  factory ContextEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContextEntry(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      type: $ContextEntriesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      value: serializer.fromJson<double>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'type': serializer.toJson<String>(
        $ContextEntriesTable.$convertertype.toJson(type),
      ),
      'value': serializer.toJson<double>(value),
    };
  }

  ContextEntry copyWith({
    int? id,
    DateTime? timestamp,
    ContextType? type,
    double? value,
  }) => ContextEntry(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    type: type ?? this.type,
    value: value ?? this.value,
  );
  ContextEntry copyWithCompanion(ContextEntriesCompanion data) {
    return ContextEntry(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContextEntry(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timestamp, type, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContextEntry &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.type == this.type &&
          other.value == this.value);
}

class ContextEntriesCompanion extends UpdateCompanion<ContextEntry> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<ContextType> type;
  final Value<double> value;
  const ContextEntriesCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
  });
  ContextEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required ContextType type,
    required double value,
  }) : timestamp = Value(timestamp),
       type = Value(type),
       value = Value(value);
  static Insertable<ContextEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? type,
    Expression<double>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
    });
  }

  ContextEntriesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<ContextType>? type,
    Value<double>? value,
  }) {
    return ContextEntriesCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $ContextEntriesTable.$convertertype.toSql(type.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContextEntriesCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $SymptomsTable extends Symptoms with TableInfo<$SymptomsTable, Symptom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Set<SymptomType>, String> types =
      GeneratedColumn<String>(
        'types',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Set<SymptomType>>($SymptomsTable.$convertertypes);
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesSinceLastMealMeta =
      const VerificationMeta('minutesSinceLastMeal');
  @override
  late final GeneratedColumn<int> minutesSinceLastMeal = GeneratedColumn<int>(
    'minutes_since_last_meal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  coincidentFactors = GeneratedColumn<String>(
    'coincident_factors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  ).withConverter<List<String>>($SymptomsTable.$convertercoincidentFactors);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    types,
    severity,
    minutesSinceLastMeal,
    note,
    coincidentFactors,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptoms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Symptom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('minutes_since_last_meal')) {
      context.handle(
        _minutesSinceLastMealMeta,
        minutesSinceLastMeal.isAcceptableOrUnknown(
          data['minutes_since_last_meal']!,
          _minutesSinceLastMealMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Symptom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Symptom(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      types: $SymptomsTable.$convertertypes.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}types'],
        )!,
      ),
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      )!,
      minutesSinceLastMeal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_since_last_meal'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      coincidentFactors: $SymptomsTable.$convertercoincidentFactors.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}coincident_factors'],
        )!,
      ),
    );
  }

  @override
  $SymptomsTable createAlias(String alias) {
    return $SymptomsTable(attachedDatabase, alias);
  }

  static TypeConverter<Set<SymptomType>, String> $convertertypes =
      const SymptomTypeSetConverter();
  static TypeConverter<List<String>, String> $convertercoincidentFactors =
      const StringListConverter();
}

class Symptom extends DataClass implements Insertable<Symptom> {
  final int id;
  final DateTime timestamp;
  final Set<SymptomType> types;
  final int severity;

  /// Derived from the last logged meal at entry time, but user-editable,
  /// because "20 minutes after eggs" and "3 hours after eggs" implicate
  /// different mechanisms.
  final int? minutesSinceLastMeal;
  final String? note;
  final List<String> coincidentFactors;
  const Symptom({
    required this.id,
    required this.timestamp,
    required this.types,
    required this.severity,
    this.minutesSinceLastMeal,
    this.note,
    required this.coincidentFactors,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    {
      map['types'] = Variable<String>(
        $SymptomsTable.$convertertypes.toSql(types),
      );
    }
    map['severity'] = Variable<int>(severity);
    if (!nullToAbsent || minutesSinceLastMeal != null) {
      map['minutes_since_last_meal'] = Variable<int>(minutesSinceLastMeal);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    {
      map['coincident_factors'] = Variable<String>(
        $SymptomsTable.$convertercoincidentFactors.toSql(coincidentFactors),
      );
    }
    return map;
  }

  SymptomsCompanion toCompanion(bool nullToAbsent) {
    return SymptomsCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      types: Value(types),
      severity: Value(severity),
      minutesSinceLastMeal: minutesSinceLastMeal == null && nullToAbsent
          ? const Value.absent()
          : Value(minutesSinceLastMeal),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      coincidentFactors: Value(coincidentFactors),
    );
  }

  factory Symptom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Symptom(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      types: serializer.fromJson<Set<SymptomType>>(json['types']),
      severity: serializer.fromJson<int>(json['severity']),
      minutesSinceLastMeal: serializer.fromJson<int?>(
        json['minutesSinceLastMeal'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      coincidentFactors: serializer.fromJson<List<String>>(
        json['coincidentFactors'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'types': serializer.toJson<Set<SymptomType>>(types),
      'severity': serializer.toJson<int>(severity),
      'minutesSinceLastMeal': serializer.toJson<int?>(minutesSinceLastMeal),
      'note': serializer.toJson<String?>(note),
      'coincidentFactors': serializer.toJson<List<String>>(coincidentFactors),
    };
  }

  Symptom copyWith({
    int? id,
    DateTime? timestamp,
    Set<SymptomType>? types,
    int? severity,
    Value<int?> minutesSinceLastMeal = const Value.absent(),
    Value<String?> note = const Value.absent(),
    List<String>? coincidentFactors,
  }) => Symptom(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    types: types ?? this.types,
    severity: severity ?? this.severity,
    minutesSinceLastMeal: minutesSinceLastMeal.present
        ? minutesSinceLastMeal.value
        : this.minutesSinceLastMeal,
    note: note.present ? note.value : this.note,
    coincidentFactors: coincidentFactors ?? this.coincidentFactors,
  );
  Symptom copyWithCompanion(SymptomsCompanion data) {
    return Symptom(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      types: data.types.present ? data.types.value : this.types,
      severity: data.severity.present ? data.severity.value : this.severity,
      minutesSinceLastMeal: data.minutesSinceLastMeal.present
          ? data.minutesSinceLastMeal.value
          : this.minutesSinceLastMeal,
      note: data.note.present ? data.note.value : this.note,
      coincidentFactors: data.coincidentFactors.present
          ? data.coincidentFactors.value
          : this.coincidentFactors,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Symptom(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('types: $types, ')
          ..write('severity: $severity, ')
          ..write('minutesSinceLastMeal: $minutesSinceLastMeal, ')
          ..write('note: $note, ')
          ..write('coincidentFactors: $coincidentFactors')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    types,
    severity,
    minutesSinceLastMeal,
    note,
    coincidentFactors,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Symptom &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.types == this.types &&
          other.severity == this.severity &&
          other.minutesSinceLastMeal == this.minutesSinceLastMeal &&
          other.note == this.note &&
          other.coincidentFactors == this.coincidentFactors);
}

class SymptomsCompanion extends UpdateCompanion<Symptom> {
  final Value<int> id;
  final Value<DateTime> timestamp;
  final Value<Set<SymptomType>> types;
  final Value<int> severity;
  final Value<int?> minutesSinceLastMeal;
  final Value<String?> note;
  final Value<List<String>> coincidentFactors;
  const SymptomsCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.types = const Value.absent(),
    this.severity = const Value.absent(),
    this.minutesSinceLastMeal = const Value.absent(),
    this.note = const Value.absent(),
    this.coincidentFactors = const Value.absent(),
  });
  SymptomsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime timestamp,
    required Set<SymptomType> types,
    required int severity,
    this.minutesSinceLastMeal = const Value.absent(),
    this.note = const Value.absent(),
    this.coincidentFactors = const Value.absent(),
  }) : timestamp = Value(timestamp),
       types = Value(types),
       severity = Value(severity);
  static Insertable<Symptom> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? types,
    Expression<int>? severity,
    Expression<int>? minutesSinceLastMeal,
    Expression<String>? note,
    Expression<String>? coincidentFactors,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (types != null) 'types': types,
      if (severity != null) 'severity': severity,
      if (minutesSinceLastMeal != null)
        'minutes_since_last_meal': minutesSinceLastMeal,
      if (note != null) 'note': note,
      if (coincidentFactors != null) 'coincident_factors': coincidentFactors,
    });
  }

  SymptomsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? timestamp,
    Value<Set<SymptomType>>? types,
    Value<int>? severity,
    Value<int?>? minutesSinceLastMeal,
    Value<String?>? note,
    Value<List<String>>? coincidentFactors,
  }) {
    return SymptomsCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      types: types ?? this.types,
      severity: severity ?? this.severity,
      minutesSinceLastMeal: minutesSinceLastMeal ?? this.minutesSinceLastMeal,
      note: note ?? this.note,
      coincidentFactors: coincidentFactors ?? this.coincidentFactors,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (types.present) {
      map['types'] = Variable<String>(
        $SymptomsTable.$convertertypes.toSql(types.value),
      );
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (minutesSinceLastMeal.present) {
      map['minutes_since_last_meal'] = Variable<int>(
        minutesSinceLastMeal.value,
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (coincidentFactors.present) {
      map['coincident_factors'] = Variable<String>(
        $SymptomsTable.$convertercoincidentFactors.toSql(
          coincidentFactors.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomsCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('types: $types, ')
          ..write('severity: $severity, ')
          ..write('minutesSinceLastMeal: $minutesSinceLastMeal, ')
          ..write('note: $note, ')
          ..write('coincidentFactors: $coincidentFactors')
          ..write(')'))
        .toString();
  }
}

class $ChallengesTable extends Challenges
    with TableInfo<$ChallengesTable, Challenge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientIdMeta = const VerificationMeta(
    'ingredientId',
  );
  @override
  late final GeneratedColumn<int> ingredientId = GeneratedColumn<int>(
    'ingredient_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ingredients (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TriggerTag?, String> tag =
      GeneratedColumn<String>(
        'tag',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TriggerTag?>($ChallengesTable.$convertertagn);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ChallengeStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ChallengeStatus>($ChallengesTable.$converterstatus);
  static const VerificationMeta _blindedMeta = const VerificationMeta(
    'blinded',
  );
  @override
  late final GeneratedColumn<bool> blinded = GeneratedColumn<bool>(
    'blinded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("blinded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ChallengeOutcome?, String>
  outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<ChallengeOutcome?>($ChallengesTable.$converteroutcomen);
  static const VerificationMeta _resultNoteMeta = const VerificationMeta(
    'resultNote',
  );
  @override
  late final GeneratedColumn<String> resultNote = GeneratedColumn<String>(
    'result_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    ingredientId,
    tag,
    createdAt,
    startDate,
    status,
    blinded,
    outcome,
    resultNote,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenges';
  @override
  VerificationContext validateIntegrity(
    Insertable<Challenge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
        _ingredientIdMeta,
        ingredientId.isAcceptableOrUnknown(
          data['ingredient_id']!,
          _ingredientIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('blinded')) {
      context.handle(
        _blindedMeta,
        blinded.isAcceptableOrUnknown(data['blinded']!, _blindedMeta),
      );
    }
    if (data.containsKey('result_note')) {
      context.handle(
        _resultNoteMeta,
        resultNote.isAcceptableOrUnknown(data['result_note']!, _resultNoteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Challenge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Challenge(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      ingredientId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ingredient_id'],
      ),
      tag: $ChallengesTable.$convertertagn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tag'],
        ),
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      status: $ChallengesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      blinded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}blinded'],
      )!,
      outcome: $ChallengesTable.$converteroutcomen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        ),
      ),
      resultNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_note'],
      ),
    );
  }

  @override
  $ChallengesTable createAlias(String alias) {
    return $ChallengesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TriggerTag, String, String> $convertertag =
      const EnumNameConverter<TriggerTag>(TriggerTag.values);
  static JsonTypeConverter2<TriggerTag?, String?, String?> $convertertagn =
      JsonTypeConverter2.asNullable($convertertag);
  static JsonTypeConverter2<ChallengeStatus, String, String> $converterstatus =
      const EnumNameConverter<ChallengeStatus>(ChallengeStatus.values);
  static JsonTypeConverter2<ChallengeOutcome, String, String>
  $converteroutcome = const EnumNameConverter<ChallengeOutcome>(
    ChallengeOutcome.values,
  );
  static JsonTypeConverter2<ChallengeOutcome?, String?, String?>
  $converteroutcomen = JsonTypeConverter2.asNullable($converteroutcome);
}

class Challenge extends DataClass implements Insertable<Challenge> {
  final int id;

  /// Display label for the candidate under test (ingredient name or tag).
  final String title;
  final int? ingredientId;
  final TriggerTag? tag;
  final DateTime createdAt;
  final DateTime startDate;
  final ChallengeStatus status;
  final bool blinded;
  final ChallengeOutcome? outcome;
  final String? resultNote;
  const Challenge({
    required this.id,
    required this.title,
    this.ingredientId,
    this.tag,
    required this.createdAt,
    required this.startDate,
    required this.status,
    required this.blinded,
    this.outcome,
    this.resultNote,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || ingredientId != null) {
      map['ingredient_id'] = Variable<int>(ingredientId);
    }
    if (!nullToAbsent || tag != null) {
      map['tag'] = Variable<String>($ChallengesTable.$convertertagn.toSql(tag));
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['start_date'] = Variable<DateTime>(startDate);
    {
      map['status'] = Variable<String>(
        $ChallengesTable.$converterstatus.toSql(status),
      );
    }
    map['blinded'] = Variable<bool>(blinded);
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(
        $ChallengesTable.$converteroutcomen.toSql(outcome),
      );
    }
    if (!nullToAbsent || resultNote != null) {
      map['result_note'] = Variable<String>(resultNote);
    }
    return map;
  }

  ChallengesCompanion toCompanion(bool nullToAbsent) {
    return ChallengesCompanion(
      id: Value(id),
      title: Value(title),
      ingredientId: ingredientId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientId),
      tag: tag == null && nullToAbsent ? const Value.absent() : Value(tag),
      createdAt: Value(createdAt),
      startDate: Value(startDate),
      status: Value(status),
      blinded: Value(blinded),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      resultNote: resultNote == null && nullToAbsent
          ? const Value.absent()
          : Value(resultNote),
    );
  }

  factory Challenge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Challenge(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      ingredientId: serializer.fromJson<int?>(json['ingredientId']),
      tag: $ChallengesTable.$convertertagn.fromJson(
        serializer.fromJson<String?>(json['tag']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      status: $ChallengesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      blinded: serializer.fromJson<bool>(json['blinded']),
      outcome: $ChallengesTable.$converteroutcomen.fromJson(
        serializer.fromJson<String?>(json['outcome']),
      ),
      resultNote: serializer.fromJson<String?>(json['resultNote']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'ingredientId': serializer.toJson<int?>(ingredientId),
      'tag': serializer.toJson<String?>(
        $ChallengesTable.$convertertagn.toJson(tag),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'startDate': serializer.toJson<DateTime>(startDate),
      'status': serializer.toJson<String>(
        $ChallengesTable.$converterstatus.toJson(status),
      ),
      'blinded': serializer.toJson<bool>(blinded),
      'outcome': serializer.toJson<String?>(
        $ChallengesTable.$converteroutcomen.toJson(outcome),
      ),
      'resultNote': serializer.toJson<String?>(resultNote),
    };
  }

  Challenge copyWith({
    int? id,
    String? title,
    Value<int?> ingredientId = const Value.absent(),
    Value<TriggerTag?> tag = const Value.absent(),
    DateTime? createdAt,
    DateTime? startDate,
    ChallengeStatus? status,
    bool? blinded,
    Value<ChallengeOutcome?> outcome = const Value.absent(),
    Value<String?> resultNote = const Value.absent(),
  }) => Challenge(
    id: id ?? this.id,
    title: title ?? this.title,
    ingredientId: ingredientId.present ? ingredientId.value : this.ingredientId,
    tag: tag.present ? tag.value : this.tag,
    createdAt: createdAt ?? this.createdAt,
    startDate: startDate ?? this.startDate,
    status: status ?? this.status,
    blinded: blinded ?? this.blinded,
    outcome: outcome.present ? outcome.value : this.outcome,
    resultNote: resultNote.present ? resultNote.value : this.resultNote,
  );
  Challenge copyWithCompanion(ChallengesCompanion data) {
    return Challenge(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      tag: data.tag.present ? data.tag.value : this.tag,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      status: data.status.present ? data.status.value : this.status,
      blinded: data.blinded.present ? data.blinded.value : this.blinded,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      resultNote: data.resultNote.present
          ? data.resultNote.value
          : this.resultNote,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Challenge(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('tag: $tag, ')
          ..write('createdAt: $createdAt, ')
          ..write('startDate: $startDate, ')
          ..write('status: $status, ')
          ..write('blinded: $blinded, ')
          ..write('outcome: $outcome, ')
          ..write('resultNote: $resultNote')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    ingredientId,
    tag,
    createdAt,
    startDate,
    status,
    blinded,
    outcome,
    resultNote,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Challenge &&
          other.id == this.id &&
          other.title == this.title &&
          other.ingredientId == this.ingredientId &&
          other.tag == this.tag &&
          other.createdAt == this.createdAt &&
          other.startDate == this.startDate &&
          other.status == this.status &&
          other.blinded == this.blinded &&
          other.outcome == this.outcome &&
          other.resultNote == this.resultNote);
}

class ChallengesCompanion extends UpdateCompanion<Challenge> {
  final Value<int> id;
  final Value<String> title;
  final Value<int?> ingredientId;
  final Value<TriggerTag?> tag;
  final Value<DateTime> createdAt;
  final Value<DateTime> startDate;
  final Value<ChallengeStatus> status;
  final Value<bool> blinded;
  final Value<ChallengeOutcome?> outcome;
  final Value<String?> resultNote;
  const ChallengesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.tag = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.startDate = const Value.absent(),
    this.status = const Value.absent(),
    this.blinded = const Value.absent(),
    this.outcome = const Value.absent(),
    this.resultNote = const Value.absent(),
  });
  ChallengesCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.ingredientId = const Value.absent(),
    this.tag = const Value.absent(),
    required DateTime createdAt,
    required DateTime startDate,
    required ChallengeStatus status,
    this.blinded = const Value.absent(),
    this.outcome = const Value.absent(),
    this.resultNote = const Value.absent(),
  }) : title = Value(title),
       createdAt = Value(createdAt),
       startDate = Value(startDate),
       status = Value(status);
  static Insertable<Challenge> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? ingredientId,
    Expression<String>? tag,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? startDate,
    Expression<String>? status,
    Expression<bool>? blinded,
    Expression<String>? outcome,
    Expression<String>? resultNote,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (tag != null) 'tag': tag,
      if (createdAt != null) 'created_at': createdAt,
      if (startDate != null) 'start_date': startDate,
      if (status != null) 'status': status,
      if (blinded != null) 'blinded': blinded,
      if (outcome != null) 'outcome': outcome,
      if (resultNote != null) 'result_note': resultNote,
    });
  }

  ChallengesCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int?>? ingredientId,
    Value<TriggerTag?>? tag,
    Value<DateTime>? createdAt,
    Value<DateTime>? startDate,
    Value<ChallengeStatus>? status,
    Value<bool>? blinded,
    Value<ChallengeOutcome?>? outcome,
    Value<String?>? resultNote,
  }) {
    return ChallengesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      ingredientId: ingredientId ?? this.ingredientId,
      tag: tag ?? this.tag,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      blinded: blinded ?? this.blinded,
      outcome: outcome ?? this.outcome,
      resultNote: resultNote ?? this.resultNote,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<int>(ingredientId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(
        $ChallengesTable.$convertertagn.toSql(tag.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ChallengesTable.$converterstatus.toSql(status.value),
      );
    }
    if (blinded.present) {
      map['blinded'] = Variable<bool>(blinded.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $ChallengesTable.$converteroutcomen.toSql(outcome.value),
      );
    }
    if (resultNote.present) {
      map['result_note'] = Variable<String>(resultNote.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('tag: $tag, ')
          ..write('createdAt: $createdAt, ')
          ..write('startDate: $startDate, ')
          ..write('status: $status, ')
          ..write('blinded: $blinded, ')
          ..write('outcome: $outcome, ')
          ..write('resultNote: $resultNote')
          ..write(')'))
        .toString();
  }
}

class $ChallengeDaysTable extends ChallengeDays
    with TableInfo<$ChallengeDaysTable, ChallengeDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChallengeDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _challengeIdMeta = const VerificationMeta(
    'challengeId',
  );
  @override
  late final GeneratedColumn<int> challengeId = GeneratedColumn<int>(
    'challenge_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES challenges (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ChallengeDayKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ChallengeDayKind>($ChallengeDaysTable.$converterkind);
  static const VerificationMeta _adheredMeta = const VerificationMeta(
    'adhered',
  );
  @override
  late final GeneratedColumn<bool> adhered = GeneratedColumn<bool>(
    'adhered',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("adhered" IN (0, 1))',
    ),
  );
  static const VerificationMeta _maxSeverityMeta = const VerificationMeta(
    'maxSeverity',
  );
  @override
  late final GeneratedColumn<int> maxSeverity = GeneratedColumn<int>(
    'max_severity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    challengeId,
    dayIndex,
    date,
    kind,
    adhered,
    maxSeverity,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'challenge_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChallengeDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('challenge_id')) {
      context.handle(
        _challengeIdMeta,
        challengeId.isAcceptableOrUnknown(
          data['challenge_id']!,
          _challengeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_challengeIdMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('adhered')) {
      context.handle(
        _adheredMeta,
        adhered.isAcceptableOrUnknown(data['adhered']!, _adheredMeta),
      );
    }
    if (data.containsKey('max_severity')) {
      context.handle(
        _maxSeverityMeta,
        maxSeverity.isAcceptableOrUnknown(
          data['max_severity']!,
          _maxSeverityMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChallengeDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChallengeDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      challengeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}challenge_id'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      kind: $ChallengeDaysTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      adhered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}adhered'],
      ),
      maxSeverity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_severity'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $ChallengeDaysTable createAlias(String alias) {
    return $ChallengeDaysTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ChallengeDayKind, String, String> $converterkind =
      const EnumNameConverter<ChallengeDayKind>(ChallengeDayKind.values);
}

class ChallengeDay extends DataClass implements Insertable<ChallengeDay> {
  final int id;
  final int challengeId;
  final int dayIndex;
  final DateTime date;
  final ChallengeDayKind kind;

  /// Did the user follow the day's instruction (eat / avoid as scheduled)?
  final bool? adhered;

  /// Worst symptom severity that day; 0 means symptom-free. Null = not logged.
  final int? maxSeverity;
  final String? note;
  const ChallengeDay({
    required this.id,
    required this.challengeId,
    required this.dayIndex,
    required this.date,
    required this.kind,
    this.adhered,
    this.maxSeverity,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['challenge_id'] = Variable<int>(challengeId);
    map['day_index'] = Variable<int>(dayIndex);
    map['date'] = Variable<DateTime>(date);
    {
      map['kind'] = Variable<String>(
        $ChallengeDaysTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || adhered != null) {
      map['adhered'] = Variable<bool>(adhered);
    }
    if (!nullToAbsent || maxSeverity != null) {
      map['max_severity'] = Variable<int>(maxSeverity);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ChallengeDaysCompanion toCompanion(bool nullToAbsent) {
    return ChallengeDaysCompanion(
      id: Value(id),
      challengeId: Value(challengeId),
      dayIndex: Value(dayIndex),
      date: Value(date),
      kind: Value(kind),
      adhered: adhered == null && nullToAbsent
          ? const Value.absent()
          : Value(adhered),
      maxSeverity: maxSeverity == null && nullToAbsent
          ? const Value.absent()
          : Value(maxSeverity),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ChallengeDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChallengeDay(
      id: serializer.fromJson<int>(json['id']),
      challengeId: serializer.fromJson<int>(json['challengeId']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      date: serializer.fromJson<DateTime>(json['date']),
      kind: $ChallengeDaysTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      adhered: serializer.fromJson<bool?>(json['adhered']),
      maxSeverity: serializer.fromJson<int?>(json['maxSeverity']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'challengeId': serializer.toJson<int>(challengeId),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'date': serializer.toJson<DateTime>(date),
      'kind': serializer.toJson<String>(
        $ChallengeDaysTable.$converterkind.toJson(kind),
      ),
      'adhered': serializer.toJson<bool?>(adhered),
      'maxSeverity': serializer.toJson<int?>(maxSeverity),
      'note': serializer.toJson<String?>(note),
    };
  }

  ChallengeDay copyWith({
    int? id,
    int? challengeId,
    int? dayIndex,
    DateTime? date,
    ChallengeDayKind? kind,
    Value<bool?> adhered = const Value.absent(),
    Value<int?> maxSeverity = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => ChallengeDay(
    id: id ?? this.id,
    challengeId: challengeId ?? this.challengeId,
    dayIndex: dayIndex ?? this.dayIndex,
    date: date ?? this.date,
    kind: kind ?? this.kind,
    adhered: adhered.present ? adhered.value : this.adhered,
    maxSeverity: maxSeverity.present ? maxSeverity.value : this.maxSeverity,
    note: note.present ? note.value : this.note,
  );
  ChallengeDay copyWithCompanion(ChallengeDaysCompanion data) {
    return ChallengeDay(
      id: data.id.present ? data.id.value : this.id,
      challengeId: data.challengeId.present
          ? data.challengeId.value
          : this.challengeId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      adhered: data.adhered.present ? data.adhered.value : this.adhered,
      maxSeverity: data.maxSeverity.present
          ? data.maxSeverity.value
          : this.maxSeverity,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeDay(')
          ..write('id: $id, ')
          ..write('challengeId: $challengeId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('adhered: $adhered, ')
          ..write('maxSeverity: $maxSeverity, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    challengeId,
    dayIndex,
    date,
    kind,
    adhered,
    maxSeverity,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeDay &&
          other.id == this.id &&
          other.challengeId == this.challengeId &&
          other.dayIndex == this.dayIndex &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.adhered == this.adhered &&
          other.maxSeverity == this.maxSeverity &&
          other.note == this.note);
}

class ChallengeDaysCompanion extends UpdateCompanion<ChallengeDay> {
  final Value<int> id;
  final Value<int> challengeId;
  final Value<int> dayIndex;
  final Value<DateTime> date;
  final Value<ChallengeDayKind> kind;
  final Value<bool?> adhered;
  final Value<int?> maxSeverity;
  final Value<String?> note;
  const ChallengeDaysCompanion({
    this.id = const Value.absent(),
    this.challengeId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.adhered = const Value.absent(),
    this.maxSeverity = const Value.absent(),
    this.note = const Value.absent(),
  });
  ChallengeDaysCompanion.insert({
    this.id = const Value.absent(),
    required int challengeId,
    required int dayIndex,
    required DateTime date,
    required ChallengeDayKind kind,
    this.adhered = const Value.absent(),
    this.maxSeverity = const Value.absent(),
    this.note = const Value.absent(),
  }) : challengeId = Value(challengeId),
       dayIndex = Value(dayIndex),
       date = Value(date),
       kind = Value(kind);
  static Insertable<ChallengeDay> custom({
    Expression<int>? id,
    Expression<int>? challengeId,
    Expression<int>? dayIndex,
    Expression<DateTime>? date,
    Expression<String>? kind,
    Expression<bool>? adhered,
    Expression<int>? maxSeverity,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (challengeId != null) 'challenge_id': challengeId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (adhered != null) 'adhered': adhered,
      if (maxSeverity != null) 'max_severity': maxSeverity,
      if (note != null) 'note': note,
    });
  }

  ChallengeDaysCompanion copyWith({
    Value<int>? id,
    Value<int>? challengeId,
    Value<int>? dayIndex,
    Value<DateTime>? date,
    Value<ChallengeDayKind>? kind,
    Value<bool?>? adhered,
    Value<int?>? maxSeverity,
    Value<String?>? note,
  }) {
    return ChallengeDaysCompanion(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      dayIndex: dayIndex ?? this.dayIndex,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      adhered: adhered ?? this.adhered,
      maxSeverity: maxSeverity ?? this.maxSeverity,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (challengeId.present) {
      map['challenge_id'] = Variable<int>(challengeId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ChallengeDaysTable.$converterkind.toSql(kind.value),
      );
    }
    if (adhered.present) {
      map['adhered'] = Variable<bool>(adhered.value);
    }
    if (maxSeverity.present) {
      map['max_severity'] = Variable<int>(maxSeverity.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChallengeDaysCompanion(')
          ..write('id: $id, ')
          ..write('challengeId: $challengeId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('adhered: $adhered, ')
          ..write('maxSeverity: $maxSeverity, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _disclaimerAcceptedMeta =
      const VerificationMeta('disclaimerAccepted');
  @override
  late final GeneratedColumn<bool> disclaimerAccepted = GeneratedColumn<bool>(
    'disclaimer_accepted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("disclaimer_accepted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _onboardingCompleteMeta =
      const VerificationMeta('onboardingComplete');
  @override
  late final GeneratedColumn<bool> onboardingComplete = GeneratedColumn<bool>(
    'onboarding_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("onboarding_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _llmProviderMeta = const VerificationMeta(
    'llmProvider',
  );
  @override
  late final GeneratedColumn<String> llmProvider = GeneratedColumn<String>(
    'llm_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _morningReminderMeta = const VerificationMeta(
    'morningReminder',
  );
  @override
  late final GeneratedColumn<bool> morningReminder = GeneratedColumn<bool>(
    'morning_reminder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("morning_reminder" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _eveningReminderMeta = const VerificationMeta(
    'eveningReminder',
  );
  @override
  late final GeneratedColumn<bool> eveningReminder = GeneratedColumn<bool>(
    'evening_reminder',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("evening_reminder" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _mealRemindersMeta = const VerificationMeta(
    'mealReminders',
  );
  @override
  late final GeneratedColumn<bool> mealReminders = GeneratedColumn<bool>(
    'meal_reminders',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("meal_reminders" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _trackMenstrualCycleMeta =
      const VerificationMeta('trackMenstrualCycle');
  @override
  late final GeneratedColumn<bool> trackMenstrualCycle = GeneratedColumn<bool>(
    'track_menstrual_cycle',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("track_menstrual_cycle" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    disclaimerAccepted,
    onboardingComplete,
    llmProvider,
    morningReminder,
    eveningReminder,
    mealReminders,
    trackMenstrualCycle,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('disclaimer_accepted')) {
      context.handle(
        _disclaimerAcceptedMeta,
        disclaimerAccepted.isAcceptableOrUnknown(
          data['disclaimer_accepted']!,
          _disclaimerAcceptedMeta,
        ),
      );
    }
    if (data.containsKey('onboarding_complete')) {
      context.handle(
        _onboardingCompleteMeta,
        onboardingComplete.isAcceptableOrUnknown(
          data['onboarding_complete']!,
          _onboardingCompleteMeta,
        ),
      );
    }
    if (data.containsKey('llm_provider')) {
      context.handle(
        _llmProviderMeta,
        llmProvider.isAcceptableOrUnknown(
          data['llm_provider']!,
          _llmProviderMeta,
        ),
      );
    }
    if (data.containsKey('morning_reminder')) {
      context.handle(
        _morningReminderMeta,
        morningReminder.isAcceptableOrUnknown(
          data['morning_reminder']!,
          _morningReminderMeta,
        ),
      );
    }
    if (data.containsKey('evening_reminder')) {
      context.handle(
        _eveningReminderMeta,
        eveningReminder.isAcceptableOrUnknown(
          data['evening_reminder']!,
          _eveningReminderMeta,
        ),
      );
    }
    if (data.containsKey('meal_reminders')) {
      context.handle(
        _mealRemindersMeta,
        mealReminders.isAcceptableOrUnknown(
          data['meal_reminders']!,
          _mealRemindersMeta,
        ),
      );
    }
    if (data.containsKey('track_menstrual_cycle')) {
      context.handle(
        _trackMenstrualCycleMeta,
        trackMenstrualCycle.isAcceptableOrUnknown(
          data['track_menstrual_cycle']!,
          _trackMenstrualCycleMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      disclaimerAccepted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}disclaimer_accepted'],
      )!,
      onboardingComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}onboarding_complete'],
      )!,
      llmProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}llm_provider'],
      ),
      morningReminder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}morning_reminder'],
      )!,
      eveningReminder: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}evening_reminder'],
      )!,
      mealReminders: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}meal_reminders'],
      )!,
      trackMenstrualCycle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}track_menstrual_cycle'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  /// Single-row table, id is always 1.
  final int id;
  final bool disclaimerAccepted;
  final bool onboardingComplete;

  /// 'anthropic' or 'openai'. The key itself lives in the iOS keychain via
  /// flutter_secure_storage, never in this database.
  final String? llmProvider;
  final bool morningReminder;
  final bool eveningReminder;
  final bool mealReminders;
  final bool trackMenstrualCycle;
  const AppSetting({
    required this.id,
    required this.disclaimerAccepted,
    required this.onboardingComplete,
    this.llmProvider,
    required this.morningReminder,
    required this.eveningReminder,
    required this.mealReminders,
    required this.trackMenstrualCycle,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['disclaimer_accepted'] = Variable<bool>(disclaimerAccepted);
    map['onboarding_complete'] = Variable<bool>(onboardingComplete);
    if (!nullToAbsent || llmProvider != null) {
      map['llm_provider'] = Variable<String>(llmProvider);
    }
    map['morning_reminder'] = Variable<bool>(morningReminder);
    map['evening_reminder'] = Variable<bool>(eveningReminder);
    map['meal_reminders'] = Variable<bool>(mealReminders);
    map['track_menstrual_cycle'] = Variable<bool>(trackMenstrualCycle);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      disclaimerAccepted: Value(disclaimerAccepted),
      onboardingComplete: Value(onboardingComplete),
      llmProvider: llmProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(llmProvider),
      morningReminder: Value(morningReminder),
      eveningReminder: Value(eveningReminder),
      mealReminders: Value(mealReminders),
      trackMenstrualCycle: Value(trackMenstrualCycle),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      disclaimerAccepted: serializer.fromJson<bool>(json['disclaimerAccepted']),
      onboardingComplete: serializer.fromJson<bool>(json['onboardingComplete']),
      llmProvider: serializer.fromJson<String?>(json['llmProvider']),
      morningReminder: serializer.fromJson<bool>(json['morningReminder']),
      eveningReminder: serializer.fromJson<bool>(json['eveningReminder']),
      mealReminders: serializer.fromJson<bool>(json['mealReminders']),
      trackMenstrualCycle: serializer.fromJson<bool>(
        json['trackMenstrualCycle'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'disclaimerAccepted': serializer.toJson<bool>(disclaimerAccepted),
      'onboardingComplete': serializer.toJson<bool>(onboardingComplete),
      'llmProvider': serializer.toJson<String?>(llmProvider),
      'morningReminder': serializer.toJson<bool>(morningReminder),
      'eveningReminder': serializer.toJson<bool>(eveningReminder),
      'mealReminders': serializer.toJson<bool>(mealReminders),
      'trackMenstrualCycle': serializer.toJson<bool>(trackMenstrualCycle),
    };
  }

  AppSetting copyWith({
    int? id,
    bool? disclaimerAccepted,
    bool? onboardingComplete,
    Value<String?> llmProvider = const Value.absent(),
    bool? morningReminder,
    bool? eveningReminder,
    bool? mealReminders,
    bool? trackMenstrualCycle,
  }) => AppSetting(
    id: id ?? this.id,
    disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    llmProvider: llmProvider.present ? llmProvider.value : this.llmProvider,
    morningReminder: morningReminder ?? this.morningReminder,
    eveningReminder: eveningReminder ?? this.eveningReminder,
    mealReminders: mealReminders ?? this.mealReminders,
    trackMenstrualCycle: trackMenstrualCycle ?? this.trackMenstrualCycle,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      disclaimerAccepted: data.disclaimerAccepted.present
          ? data.disclaimerAccepted.value
          : this.disclaimerAccepted,
      onboardingComplete: data.onboardingComplete.present
          ? data.onboardingComplete.value
          : this.onboardingComplete,
      llmProvider: data.llmProvider.present
          ? data.llmProvider.value
          : this.llmProvider,
      morningReminder: data.morningReminder.present
          ? data.morningReminder.value
          : this.morningReminder,
      eveningReminder: data.eveningReminder.present
          ? data.eveningReminder.value
          : this.eveningReminder,
      mealReminders: data.mealReminders.present
          ? data.mealReminders.value
          : this.mealReminders,
      trackMenstrualCycle: data.trackMenstrualCycle.present
          ? data.trackMenstrualCycle.value
          : this.trackMenstrualCycle,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('disclaimerAccepted: $disclaimerAccepted, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('llmProvider: $llmProvider, ')
          ..write('morningReminder: $morningReminder, ')
          ..write('eveningReminder: $eveningReminder, ')
          ..write('mealReminders: $mealReminders, ')
          ..write('trackMenstrualCycle: $trackMenstrualCycle')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    disclaimerAccepted,
    onboardingComplete,
    llmProvider,
    morningReminder,
    eveningReminder,
    mealReminders,
    trackMenstrualCycle,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.disclaimerAccepted == this.disclaimerAccepted &&
          other.onboardingComplete == this.onboardingComplete &&
          other.llmProvider == this.llmProvider &&
          other.morningReminder == this.morningReminder &&
          other.eveningReminder == this.eveningReminder &&
          other.mealReminders == this.mealReminders &&
          other.trackMenstrualCycle == this.trackMenstrualCycle);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<bool> disclaimerAccepted;
  final Value<bool> onboardingComplete;
  final Value<String?> llmProvider;
  final Value<bool> morningReminder;
  final Value<bool> eveningReminder;
  final Value<bool> mealReminders;
  final Value<bool> trackMenstrualCycle;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.disclaimerAccepted = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.llmProvider = const Value.absent(),
    this.morningReminder = const Value.absent(),
    this.eveningReminder = const Value.absent(),
    this.mealReminders = const Value.absent(),
    this.trackMenstrualCycle = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.disclaimerAccepted = const Value.absent(),
    this.onboardingComplete = const Value.absent(),
    this.llmProvider = const Value.absent(),
    this.morningReminder = const Value.absent(),
    this.eveningReminder = const Value.absent(),
    this.mealReminders = const Value.absent(),
    this.trackMenstrualCycle = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<bool>? disclaimerAccepted,
    Expression<bool>? onboardingComplete,
    Expression<String>? llmProvider,
    Expression<bool>? morningReminder,
    Expression<bool>? eveningReminder,
    Expression<bool>? mealReminders,
    Expression<bool>? trackMenstrualCycle,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (disclaimerAccepted != null) 'disclaimer_accepted': disclaimerAccepted,
      if (onboardingComplete != null) 'onboarding_complete': onboardingComplete,
      if (llmProvider != null) 'llm_provider': llmProvider,
      if (morningReminder != null) 'morning_reminder': morningReminder,
      if (eveningReminder != null) 'evening_reminder': eveningReminder,
      if (mealReminders != null) 'meal_reminders': mealReminders,
      if (trackMenstrualCycle != null)
        'track_menstrual_cycle': trackMenstrualCycle,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<bool>? disclaimerAccepted,
    Value<bool>? onboardingComplete,
    Value<String?>? llmProvider,
    Value<bool>? morningReminder,
    Value<bool>? eveningReminder,
    Value<bool>? mealReminders,
    Value<bool>? trackMenstrualCycle,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      disclaimerAccepted: disclaimerAccepted ?? this.disclaimerAccepted,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      llmProvider: llmProvider ?? this.llmProvider,
      morningReminder: morningReminder ?? this.morningReminder,
      eveningReminder: eveningReminder ?? this.eveningReminder,
      mealReminders: mealReminders ?? this.mealReminders,
      trackMenstrualCycle: trackMenstrualCycle ?? this.trackMenstrualCycle,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (disclaimerAccepted.present) {
      map['disclaimer_accepted'] = Variable<bool>(disclaimerAccepted.value);
    }
    if (onboardingComplete.present) {
      map['onboarding_complete'] = Variable<bool>(onboardingComplete.value);
    }
    if (llmProvider.present) {
      map['llm_provider'] = Variable<String>(llmProvider.value);
    }
    if (morningReminder.present) {
      map['morning_reminder'] = Variable<bool>(morningReminder.value);
    }
    if (eveningReminder.present) {
      map['evening_reminder'] = Variable<bool>(eveningReminder.value);
    }
    if (mealReminders.present) {
      map['meal_reminders'] = Variable<bool>(mealReminders.value);
    }
    if (trackMenstrualCycle.present) {
      map['track_menstrual_cycle'] = Variable<bool>(trackMenstrualCycle.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('disclaimerAccepted: $disclaimerAccepted, ')
          ..write('onboardingComplete: $onboardingComplete, ')
          ..write('llmProvider: $llmProvider, ')
          ..write('morningReminder: $morningReminder, ')
          ..write('eveningReminder: $eveningReminder, ')
          ..write('mealReminders: $mealReminders, ')
          ..write('trackMenstrualCycle: $trackMenstrualCycle')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MealsTable meals = $MealsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $MealIngredientsTable mealIngredients = $MealIngredientsTable(
    this,
  );
  late final $ContextEntriesTable contextEntries = $ContextEntriesTable(this);
  late final $SymptomsTable symptoms = $SymptomsTable(this);
  late final $ChallengesTable challenges = $ChallengesTable(this);
  late final $ChallengeDaysTable challengeDays = $ChallengeDaysTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    meals,
    ingredients,
    mealIngredients,
    contextEntries,
    symptoms,
    challenges,
    challengeDays,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'meals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('meal_ingredients', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ingredients',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('meal_ingredients', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'challenges',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('challenge_days', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MealsTableCreateCompanionBuilder =
    MealsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      Value<String?> photoPath,
      Value<String?> note,
      required PortionSize portionSize,
      required MealSource source,
    });
typedef $$MealsTableUpdateCompanionBuilder =
    MealsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<String?> photoPath,
      Value<String?> note,
      Value<PortionSize> portionSize,
      Value<MealSource> source,
    });

final class $$MealsTableReferences
    extends BaseReferences<_$AppDatabase, $MealsTable, Meal> {
  $$MealsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MealIngredientsTable, List<MealIngredient>>
  _mealIngredientsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mealIngredients,
    aliasName: 'meals__id__meal_ingredients__meal_id',
  );

  $$MealIngredientsTableProcessedTableManager get mealIngredientsRefs {
    final manager = $$MealIngredientsTableTableManager(
      $_db,
      $_db.mealIngredients,
    ).filter((f) => f.mealId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mealIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MealsTableFilterComposer extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PortionSize, PortionSize, String>
  get portionSize => $composableBuilder(
    column: $table.portionSize,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MealSource, MealSource, String> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> mealIngredientsRefs(
    Expression<bool> Function($$MealIngredientsTableFilterComposer f) f,
  ) {
    final $$MealIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealIngredients,
      getReferencedColumn: (t) => t.mealId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.mealIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MealsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portionSize => $composableBuilder(
    column: $table.portionSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealsTable> {
  $$MealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PortionSize, String> get portionSize =>
      $composableBuilder(
        column: $table.portionSize,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<MealSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  Expression<T> mealIngredientsRefs<T extends Object>(
    Expression<T> Function($$MealIngredientsTableAnnotationComposer a) f,
  ) {
    final $$MealIngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealIngredients,
      getReferencedColumn: (t) => t.mealId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealIngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.mealIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MealsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealsTable,
          Meal,
          $$MealsTableFilterComposer,
          $$MealsTableOrderingComposer,
          $$MealsTableAnnotationComposer,
          $$MealsTableCreateCompanionBuilder,
          $$MealsTableUpdateCompanionBuilder,
          (Meal, $$MealsTableReferences),
          Meal,
          PrefetchHooks Function({bool mealIngredientsRefs})
        > {
  $$MealsTableTableManager(_$AppDatabase db, $MealsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<PortionSize> portionSize = const Value.absent(),
                Value<MealSource> source = const Value.absent(),
              }) => MealsCompanion(
                id: id,
                timestamp: timestamp,
                photoPath: photoPath,
                note: note,
                portionSize: portionSize,
                source: source,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required PortionSize portionSize,
                required MealSource source,
              }) => MealsCompanion.insert(
                id: id,
                timestamp: timestamp,
                photoPath: photoPath,
                note: note,
                portionSize: portionSize,
                source: source,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$MealsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({mealIngredientsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mealIngredientsRefs) db.mealIngredients,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mealIngredientsRefs)
                    await $_getPrefetchedData<
                      Meal,
                      $MealsTable,
                      MealIngredient
                    >(
                      currentTable: table,
                      referencedTable: $$MealsTableReferences
                          ._mealIngredientsRefsTable(db),
                      managerFromTypedResult: (p0) => $$MealsTableReferences(
                        db,
                        table,
                        p0,
                      ).mealIngredientsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.mealId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MealsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealsTable,
      Meal,
      $$MealsTableFilterComposer,
      $$MealsTableOrderingComposer,
      $$MealsTableAnnotationComposer,
      $$MealsTableCreateCompanionBuilder,
      $$MealsTableUpdateCompanionBuilder,
      (Meal, $$MealsTableReferences),
      Meal,
      PrefetchHooks Function({bool mealIngredientsRefs})
    >;
typedef $$IngredientsTableCreateCompanionBuilder =
    IngredientsCompanion Function({
      Value<int> id,
      required String canonicalName,
      Value<Set<TriggerTag>> triggerTags,
    });
typedef $$IngredientsTableUpdateCompanionBuilder =
    IngredientsCompanion Function({
      Value<int> id,
      Value<String> canonicalName,
      Value<Set<TriggerTag>> triggerTags,
    });

final class $$IngredientsTableReferences
    extends BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient> {
  $$IngredientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MealIngredientsTable, List<MealIngredient>>
  _mealIngredientsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mealIngredients,
    aliasName: 'ingredients__id__meal_ingredients__ingredient_id',
  );

  $$MealIngredientsTableProcessedTableManager get mealIngredientsRefs {
    final manager = $$MealIngredientsTableTableManager(
      $_db,
      $_db.mealIngredients,
    ).filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mealIngredientsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ChallengesTable, List<Challenge>>
  _challengesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.challenges,
    aliasName: 'ingredients__id__challenges__ingredient_id',
  );

  $$ChallengesTableProcessedTableManager get challengesRefs {
    final manager = $$ChallengesTableTableManager(
      $_db,
      $_db.challenges,
    ).filter((f) => f.ingredientId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_challengesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<TriggerTag>, Set<TriggerTag>, String>
  get triggerTags => $composableBuilder(
    column: $table.triggerTags,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> mealIngredientsRefs(
    Expression<bool> Function($$MealIngredientsTableFilterComposer f) f,
  ) {
    final $$MealIngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealIngredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealIngredientsTableFilterComposer(
            $db: $db,
            $table: $db.mealIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> challengesRefs(
    Expression<bool> Function($$ChallengesTableFilterComposer f) f,
  ) {
    final $$ChallengesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.challenges,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChallengesTableFilterComposer(
            $db: $db,
            $table: $db.challenges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerTags => $composableBuilder(
    column: $table.triggerTags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Set<TriggerTag>, String> get triggerTags =>
      $composableBuilder(
        column: $table.triggerTags,
        builder: (column) => column,
      );

  Expression<T> mealIngredientsRefs<T extends Object>(
    Expression<T> Function($$MealIngredientsTableAnnotationComposer a) f,
  ) {
    final $$MealIngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mealIngredients,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealIngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.mealIngredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> challengesRefs<T extends Object>(
    Expression<T> Function($$ChallengesTableAnnotationComposer a) f,
  ) {
    final $$ChallengesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.challenges,
      getReferencedColumn: (t) => t.ingredientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChallengesTableAnnotationComposer(
            $db: $db,
            $table: $db.challenges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$IngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IngredientsTable,
          Ingredient,
          $$IngredientsTableFilterComposer,
          $$IngredientsTableOrderingComposer,
          $$IngredientsTableAnnotationComposer,
          $$IngredientsTableCreateCompanionBuilder,
          $$IngredientsTableUpdateCompanionBuilder,
          (Ingredient, $$IngredientsTableReferences),
          Ingredient,
          PrefetchHooks Function({
            bool mealIngredientsRefs,
            bool challengesRefs,
          })
        > {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> canonicalName = const Value.absent(),
                Value<Set<TriggerTag>> triggerTags = const Value.absent(),
              }) => IngredientsCompanion(
                id: id,
                canonicalName: canonicalName,
                triggerTags: triggerTags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String canonicalName,
                Value<Set<TriggerTag>> triggerTags = const Value.absent(),
              }) => IngredientsCompanion.insert(
                id: id,
                canonicalName: canonicalName,
                triggerTags: triggerTags,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mealIngredientsRefs = false, challengesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mealIngredientsRefs) db.mealIngredients,
                    if (challengesRefs) db.challenges,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mealIngredientsRefs)
                        await $_getPrefetchedData<
                          Ingredient,
                          $IngredientsTable,
                          MealIngredient
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._mealIngredientsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).mealIngredientsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (challengesRefs)
                        await $_getPrefetchedData<
                          Ingredient,
                          $IngredientsTable,
                          Challenge
                        >(
                          currentTable: table,
                          referencedTable: $$IngredientsTableReferences
                              ._challengesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$IngredientsTableReferences(
                                db,
                                table,
                                p0,
                              ).challengesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ingredientId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$IngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IngredientsTable,
      Ingredient,
      $$IngredientsTableFilterComposer,
      $$IngredientsTableOrderingComposer,
      $$IngredientsTableAnnotationComposer,
      $$IngredientsTableCreateCompanionBuilder,
      $$IngredientsTableUpdateCompanionBuilder,
      (Ingredient, $$IngredientsTableReferences),
      Ingredient,
      PrefetchHooks Function({bool mealIngredientsRefs, bool challengesRefs})
    >;
typedef $$MealIngredientsTableCreateCompanionBuilder =
    MealIngredientsCompanion Function({
      required int mealId,
      required int ingredientId,
      required IngredientConfidence confidence,
      Value<int> rowid,
    });
typedef $$MealIngredientsTableUpdateCompanionBuilder =
    MealIngredientsCompanion Function({
      Value<int> mealId,
      Value<int> ingredientId,
      Value<IngredientConfidence> confidence,
      Value<int> rowid,
    });

final class $$MealIngredientsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MealIngredientsTable, MealIngredient> {
  $$MealIngredientsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MealsTable _mealIdTable(_$AppDatabase db) =>
      db.meals.createAlias('meal_ingredients__meal_id__meals__id');

  $$MealsTableProcessedTableManager get mealId {
    final $_column = $_itemColumn<int>('meal_id')!;

    final manager = $$MealsTableTableManager(
      $_db,
      $_db.meals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mealIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) => db
      .ingredients
      .createAlias('meal_ingredients__ingredient_id__ingredients__id');

  $$IngredientsTableProcessedTableManager get ingredientId {
    final $_column = $_itemColumn<int>('ingredient_id')!;

    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MealIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $MealIngredientsTable> {
  $$MealIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<
    IngredientConfidence,
    IngredientConfidence,
    String
  >
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$MealsTableFilterComposer get mealId {
    final $$MealsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.meals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealsTableFilterComposer(
            $db: $db,
            $table: $db.meals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $MealIngredientsTable> {
  $$MealIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$MealsTableOrderingComposer get mealId {
    final $$MealsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.meals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealsTableOrderingComposer(
            $db: $db,
            $table: $db.meals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealIngredientsTable> {
  $$MealIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<IngredientConfidence, String>
  get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  $$MealsTableAnnotationComposer get mealId {
    final $$MealsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mealId,
      referencedTable: $db.meals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MealsTableAnnotationComposer(
            $db: $db,
            $table: $db.meals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MealIngredientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealIngredientsTable,
          MealIngredient,
          $$MealIngredientsTableFilterComposer,
          $$MealIngredientsTableOrderingComposer,
          $$MealIngredientsTableAnnotationComposer,
          $$MealIngredientsTableCreateCompanionBuilder,
          $$MealIngredientsTableUpdateCompanionBuilder,
          (MealIngredient, $$MealIngredientsTableReferences),
          MealIngredient,
          PrefetchHooks Function({bool mealId, bool ingredientId})
        > {
  $$MealIngredientsTableTableManager(
    _$AppDatabase db,
    $MealIngredientsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealIngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> mealId = const Value.absent(),
                Value<int> ingredientId = const Value.absent(),
                Value<IngredientConfidence> confidence = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealIngredientsCompanion(
                mealId: mealId,
                ingredientId: ingredientId,
                confidence: confidence,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int mealId,
                required int ingredientId,
                required IngredientConfidence confidence,
                Value<int> rowid = const Value.absent(),
              }) => MealIngredientsCompanion.insert(
                mealId: mealId,
                ingredientId: ingredientId,
                confidence: confidence,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MealIngredientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mealId = false, ingredientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (mealId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mealId,
                                referencedTable:
                                    $$MealIngredientsTableReferences
                                        ._mealIdTable(db),
                                referencedColumn:
                                    $$MealIngredientsTableReferences
                                        ._mealIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (ingredientId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ingredientId,
                                referencedTable:
                                    $$MealIngredientsTableReferences
                                        ._ingredientIdTable(db),
                                referencedColumn:
                                    $$MealIngredientsTableReferences
                                        ._ingredientIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MealIngredientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealIngredientsTable,
      MealIngredient,
      $$MealIngredientsTableFilterComposer,
      $$MealIngredientsTableOrderingComposer,
      $$MealIngredientsTableAnnotationComposer,
      $$MealIngredientsTableCreateCompanionBuilder,
      $$MealIngredientsTableUpdateCompanionBuilder,
      (MealIngredient, $$MealIngredientsTableReferences),
      MealIngredient,
      PrefetchHooks Function({bool mealId, bool ingredientId})
    >;
typedef $$ContextEntriesTableCreateCompanionBuilder =
    ContextEntriesCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      required ContextType type,
      required double value,
    });
typedef $$ContextEntriesTableUpdateCompanionBuilder =
    ContextEntriesCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<ContextType> type,
      Value<double> value,
    });

class $$ContextEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ContextEntriesTable> {
  $$ContextEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ContextType, ContextType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContextEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ContextEntriesTable> {
  $$ContextEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContextEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContextEntriesTable> {
  $$ContextEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContextType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$ContextEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContextEntriesTable,
          ContextEntry,
          $$ContextEntriesTableFilterComposer,
          $$ContextEntriesTableOrderingComposer,
          $$ContextEntriesTableAnnotationComposer,
          $$ContextEntriesTableCreateCompanionBuilder,
          $$ContextEntriesTableUpdateCompanionBuilder,
          (
            ContextEntry,
            BaseReferences<_$AppDatabase, $ContextEntriesTable, ContextEntry>,
          ),
          ContextEntry,
          PrefetchHooks Function()
        > {
  $$ContextEntriesTableTableManager(
    _$AppDatabase db,
    $ContextEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContextEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContextEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContextEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<ContextType> type = const Value.absent(),
                Value<double> value = const Value.absent(),
              }) => ContextEntriesCompanion(
                id: id,
                timestamp: timestamp,
                type: type,
                value: value,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required ContextType type,
                required double value,
              }) => ContextEntriesCompanion.insert(
                id: id,
                timestamp: timestamp,
                type: type,
                value: value,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContextEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContextEntriesTable,
      ContextEntry,
      $$ContextEntriesTableFilterComposer,
      $$ContextEntriesTableOrderingComposer,
      $$ContextEntriesTableAnnotationComposer,
      $$ContextEntriesTableCreateCompanionBuilder,
      $$ContextEntriesTableUpdateCompanionBuilder,
      (
        ContextEntry,
        BaseReferences<_$AppDatabase, $ContextEntriesTable, ContextEntry>,
      ),
      ContextEntry,
      PrefetchHooks Function()
    >;
typedef $$SymptomsTableCreateCompanionBuilder =
    SymptomsCompanion Function({
      Value<int> id,
      required DateTime timestamp,
      required Set<SymptomType> types,
      required int severity,
      Value<int?> minutesSinceLastMeal,
      Value<String?> note,
      Value<List<String>> coincidentFactors,
    });
typedef $$SymptomsTableUpdateCompanionBuilder =
    SymptomsCompanion Function({
      Value<int> id,
      Value<DateTime> timestamp,
      Value<Set<SymptomType>> types,
      Value<int> severity,
      Value<int?> minutesSinceLastMeal,
      Value<String?> note,
      Value<List<String>> coincidentFactors,
    });

class $$SymptomsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Set<SymptomType>, Set<SymptomType>, String>
  get types => $composableBuilder(
    column: $table.types,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesSinceLastMeal => $composableBuilder(
    column: $table.minutesSinceLastMeal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get coincidentFactors => $composableBuilder(
    column: $table.coincidentFactors,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$SymptomsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get types => $composableBuilder(
    column: $table.types,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesSinceLastMeal => $composableBuilder(
    column: $table.minutesSinceLastMeal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coincidentFactors => $composableBuilder(
    column: $table.coincidentFactors,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SymptomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<SymptomType>, String> get types =>
      $composableBuilder(column: $table.types, builder: (column) => column);

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<int> get minutesSinceLastMeal => $composableBuilder(
    column: $table.minutesSinceLastMeal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String>
  get coincidentFactors => $composableBuilder(
    column: $table.coincidentFactors,
    builder: (column) => column,
  );
}

class $$SymptomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SymptomsTable,
          Symptom,
          $$SymptomsTableFilterComposer,
          $$SymptomsTableOrderingComposer,
          $$SymptomsTableAnnotationComposer,
          $$SymptomsTableCreateCompanionBuilder,
          $$SymptomsTableUpdateCompanionBuilder,
          (Symptom, BaseReferences<_$AppDatabase, $SymptomsTable, Symptom>),
          Symptom,
          PrefetchHooks Function()
        > {
  $$SymptomsTableTableManager(_$AppDatabase db, $SymptomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<Set<SymptomType>> types = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<int?> minutesSinceLastMeal = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<List<String>> coincidentFactors = const Value.absent(),
              }) => SymptomsCompanion(
                id: id,
                timestamp: timestamp,
                types: types,
                severity: severity,
                minutesSinceLastMeal: minutesSinceLastMeal,
                note: note,
                coincidentFactors: coincidentFactors,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime timestamp,
                required Set<SymptomType> types,
                required int severity,
                Value<int?> minutesSinceLastMeal = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<List<String>> coincidentFactors = const Value.absent(),
              }) => SymptomsCompanion.insert(
                id: id,
                timestamp: timestamp,
                types: types,
                severity: severity,
                minutesSinceLastMeal: minutesSinceLastMeal,
                note: note,
                coincidentFactors: coincidentFactors,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SymptomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SymptomsTable,
      Symptom,
      $$SymptomsTableFilterComposer,
      $$SymptomsTableOrderingComposer,
      $$SymptomsTableAnnotationComposer,
      $$SymptomsTableCreateCompanionBuilder,
      $$SymptomsTableUpdateCompanionBuilder,
      (Symptom, BaseReferences<_$AppDatabase, $SymptomsTable, Symptom>),
      Symptom,
      PrefetchHooks Function()
    >;
typedef $$ChallengesTableCreateCompanionBuilder =
    ChallengesCompanion Function({
      Value<int> id,
      required String title,
      Value<int?> ingredientId,
      Value<TriggerTag?> tag,
      required DateTime createdAt,
      required DateTime startDate,
      required ChallengeStatus status,
      Value<bool> blinded,
      Value<ChallengeOutcome?> outcome,
      Value<String?> resultNote,
    });
typedef $$ChallengesTableUpdateCompanionBuilder =
    ChallengesCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int?> ingredientId,
      Value<TriggerTag?> tag,
      Value<DateTime> createdAt,
      Value<DateTime> startDate,
      Value<ChallengeStatus> status,
      Value<bool> blinded,
      Value<ChallengeOutcome?> outcome,
      Value<String?> resultNote,
    });

final class $$ChallengesTableReferences
    extends BaseReferences<_$AppDatabase, $ChallengesTable, Challenge> {
  $$ChallengesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $IngredientsTable _ingredientIdTable(_$AppDatabase db) =>
      db.ingredients.createAlias('challenges__ingredient_id__ingredients__id');

  $$IngredientsTableProcessedTableManager? get ingredientId {
    final $_column = $_itemColumn<int>('ingredient_id');
    if ($_column == null) return null;
    final manager = $$IngredientsTableTableManager(
      $_db,
      $_db.ingredients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ingredientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ChallengeDaysTable, List<ChallengeDay>>
  _challengeDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.challengeDays,
    aliasName: 'challenges__id__challenge_days__challenge_id',
  );

  $$ChallengeDaysTableProcessedTableManager get challengeDaysRefs {
    final manager = $$ChallengeDaysTableTableManager(
      $_db,
      $_db.challengeDays,
    ).filter((f) => f.challengeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_challengeDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChallengesTableFilterComposer
    extends Composer<_$AppDatabase, $ChallengesTable> {
  $$ChallengesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TriggerTag?, TriggerTag, String> get tag =>
      $composableBuilder(
        column: $table.tag,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ChallengeStatus, ChallengeStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get blinded => $composableBuilder(
    column: $table.blinded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ChallengeOutcome?, ChallengeOutcome, String>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get resultNote => $composableBuilder(
    column: $table.resultNote,
    builder: (column) => ColumnFilters(column),
  );

  $$IngredientsTableFilterComposer get ingredientId {
    final $$IngredientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableFilterComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> challengeDaysRefs(
    Expression<bool> Function($$ChallengeDaysTableFilterComposer f) f,
  ) {
    final $$ChallengeDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.challengeDays,
      getReferencedColumn: (t) => t.challengeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChallengeDaysTableFilterComposer(
            $db: $db,
            $table: $db.challengeDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChallengesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChallengesTable> {
  $$ChallengesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get blinded => $composableBuilder(
    column: $table.blinded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultNote => $composableBuilder(
    column: $table.resultNote,
    builder: (column) => ColumnOrderings(column),
  );

  $$IngredientsTableOrderingComposer get ingredientId {
    final $$IngredientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableOrderingComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChallengesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChallengesTable> {
  $$ChallengesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TriggerTag?, String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ChallengeStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get blinded =>
      $composableBuilder(column: $table.blinded, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ChallengeOutcome?, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get resultNote => $composableBuilder(
    column: $table.resultNote,
    builder: (column) => column,
  );

  $$IngredientsTableAnnotationComposer get ingredientId {
    final $$IngredientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ingredientId,
      referencedTable: $db.ingredients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IngredientsTableAnnotationComposer(
            $db: $db,
            $table: $db.ingredients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> challengeDaysRefs<T extends Object>(
    Expression<T> Function($$ChallengeDaysTableAnnotationComposer a) f,
  ) {
    final $$ChallengeDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.challengeDays,
      getReferencedColumn: (t) => t.challengeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChallengeDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.challengeDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChallengesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChallengesTable,
          Challenge,
          $$ChallengesTableFilterComposer,
          $$ChallengesTableOrderingComposer,
          $$ChallengesTableAnnotationComposer,
          $$ChallengesTableCreateCompanionBuilder,
          $$ChallengesTableUpdateCompanionBuilder,
          (Challenge, $$ChallengesTableReferences),
          Challenge,
          PrefetchHooks Function({bool ingredientId, bool challengeDaysRefs})
        > {
  $$ChallengesTableTableManager(_$AppDatabase db, $ChallengesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> ingredientId = const Value.absent(),
                Value<TriggerTag?> tag = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<ChallengeStatus> status = const Value.absent(),
                Value<bool> blinded = const Value.absent(),
                Value<ChallengeOutcome?> outcome = const Value.absent(),
                Value<String?> resultNote = const Value.absent(),
              }) => ChallengesCompanion(
                id: id,
                title: title,
                ingredientId: ingredientId,
                tag: tag,
                createdAt: createdAt,
                startDate: startDate,
                status: status,
                blinded: blinded,
                outcome: outcome,
                resultNote: resultNote,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<int?> ingredientId = const Value.absent(),
                Value<TriggerTag?> tag = const Value.absent(),
                required DateTime createdAt,
                required DateTime startDate,
                required ChallengeStatus status,
                Value<bool> blinded = const Value.absent(),
                Value<ChallengeOutcome?> outcome = const Value.absent(),
                Value<String?> resultNote = const Value.absent(),
              }) => ChallengesCompanion.insert(
                id: id,
                title: title,
                ingredientId: ingredientId,
                tag: tag,
                createdAt: createdAt,
                startDate: startDate,
                status: status,
                blinded: blinded,
                outcome: outcome,
                resultNote: resultNote,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChallengesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ingredientId = false, challengeDaysRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (challengeDaysRefs) db.challengeDays,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (ingredientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ingredientId,
                                    referencedTable: $$ChallengesTableReferences
                                        ._ingredientIdTable(db),
                                    referencedColumn:
                                        $$ChallengesTableReferences
                                            ._ingredientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (challengeDaysRefs)
                        await $_getPrefetchedData<
                          Challenge,
                          $ChallengesTable,
                          ChallengeDay
                        >(
                          currentTable: table,
                          referencedTable: $$ChallengesTableReferences
                              ._challengeDaysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChallengesTableReferences(
                                db,
                                table,
                                p0,
                              ).challengeDaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.challengeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ChallengesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChallengesTable,
      Challenge,
      $$ChallengesTableFilterComposer,
      $$ChallengesTableOrderingComposer,
      $$ChallengesTableAnnotationComposer,
      $$ChallengesTableCreateCompanionBuilder,
      $$ChallengesTableUpdateCompanionBuilder,
      (Challenge, $$ChallengesTableReferences),
      Challenge,
      PrefetchHooks Function({bool ingredientId, bool challengeDaysRefs})
    >;
typedef $$ChallengeDaysTableCreateCompanionBuilder =
    ChallengeDaysCompanion Function({
      Value<int> id,
      required int challengeId,
      required int dayIndex,
      required DateTime date,
      required ChallengeDayKind kind,
      Value<bool?> adhered,
      Value<int?> maxSeverity,
      Value<String?> note,
    });
typedef $$ChallengeDaysTableUpdateCompanionBuilder =
    ChallengeDaysCompanion Function({
      Value<int> id,
      Value<int> challengeId,
      Value<int> dayIndex,
      Value<DateTime> date,
      Value<ChallengeDayKind> kind,
      Value<bool?> adhered,
      Value<int?> maxSeverity,
      Value<String?> note,
    });

final class $$ChallengeDaysTableReferences
    extends BaseReferences<_$AppDatabase, $ChallengeDaysTable, ChallengeDay> {
  $$ChallengeDaysTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChallengesTable _challengeIdTable(_$AppDatabase db) =>
      db.challenges.createAlias('challenge_days__challenge_id__challenges__id');

  $$ChallengesTableProcessedTableManager get challengeId {
    final $_column = $_itemColumn<int>('challenge_id')!;

    final manager = $$ChallengesTableTableManager(
      $_db,
      $_db.challenges,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_challengeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ChallengeDaysTableFilterComposer
    extends Composer<_$AppDatabase, $ChallengeDaysTable> {
  $$ChallengeDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ChallengeDayKind, ChallengeDayKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get adhered => $composableBuilder(
    column: $table.adhered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxSeverity => $composableBuilder(
    column: $table.maxSeverity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$ChallengesTableFilterComposer get challengeId {
    final $$ChallengesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.challengeId,
      referencedTable: $db.challenges,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChallengesTableFilterComposer(
            $db: $db,
            $table: $db.challenges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChallengeDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $ChallengeDaysTable> {
  $$ChallengeDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get adhered => $composableBuilder(
    column: $table.adhered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxSeverity => $composableBuilder(
    column: $table.maxSeverity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChallengesTableOrderingComposer get challengeId {
    final $$ChallengesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.challengeId,
      referencedTable: $db.challenges,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChallengesTableOrderingComposer(
            $db: $db,
            $table: $db.challenges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChallengeDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChallengeDaysTable> {
  $$ChallengeDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ChallengeDayKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get adhered =>
      $composableBuilder(column: $table.adhered, builder: (column) => column);

  GeneratedColumn<int> get maxSeverity => $composableBuilder(
    column: $table.maxSeverity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$ChallengesTableAnnotationComposer get challengeId {
    final $$ChallengesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.challengeId,
      referencedTable: $db.challenges,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChallengesTableAnnotationComposer(
            $db: $db,
            $table: $db.challenges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ChallengeDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChallengeDaysTable,
          ChallengeDay,
          $$ChallengeDaysTableFilterComposer,
          $$ChallengeDaysTableOrderingComposer,
          $$ChallengeDaysTableAnnotationComposer,
          $$ChallengeDaysTableCreateCompanionBuilder,
          $$ChallengeDaysTableUpdateCompanionBuilder,
          (ChallengeDay, $$ChallengeDaysTableReferences),
          ChallengeDay,
          PrefetchHooks Function({bool challengeId})
        > {
  $$ChallengeDaysTableTableManager(_$AppDatabase db, $ChallengeDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChallengeDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChallengeDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChallengeDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> challengeId = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<ChallengeDayKind> kind = const Value.absent(),
                Value<bool?> adhered = const Value.absent(),
                Value<int?> maxSeverity = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => ChallengeDaysCompanion(
                id: id,
                challengeId: challengeId,
                dayIndex: dayIndex,
                date: date,
                kind: kind,
                adhered: adhered,
                maxSeverity: maxSeverity,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int challengeId,
                required int dayIndex,
                required DateTime date,
                required ChallengeDayKind kind,
                Value<bool?> adhered = const Value.absent(),
                Value<int?> maxSeverity = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => ChallengeDaysCompanion.insert(
                id: id,
                challengeId: challengeId,
                dayIndex: dayIndex,
                date: date,
                kind: kind,
                adhered: adhered,
                maxSeverity: maxSeverity,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChallengeDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({challengeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (challengeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.challengeId,
                                referencedTable: $$ChallengeDaysTableReferences
                                    ._challengeIdTable(db),
                                referencedColumn: $$ChallengeDaysTableReferences
                                    ._challengeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ChallengeDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChallengeDaysTable,
      ChallengeDay,
      $$ChallengeDaysTableFilterComposer,
      $$ChallengeDaysTableOrderingComposer,
      $$ChallengeDaysTableAnnotationComposer,
      $$ChallengeDaysTableCreateCompanionBuilder,
      $$ChallengeDaysTableUpdateCompanionBuilder,
      (ChallengeDay, $$ChallengeDaysTableReferences),
      ChallengeDay,
      PrefetchHooks Function({bool challengeId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> disclaimerAccepted,
      Value<bool> onboardingComplete,
      Value<String?> llmProvider,
      Value<bool> morningReminder,
      Value<bool> eveningReminder,
      Value<bool> mealReminders,
      Value<bool> trackMenstrualCycle,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<bool> disclaimerAccepted,
      Value<bool> onboardingComplete,
      Value<String?> llmProvider,
      Value<bool> morningReminder,
      Value<bool> eveningReminder,
      Value<bool> mealReminders,
      Value<bool> trackMenstrualCycle,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get disclaimerAccepted => $composableBuilder(
    column: $table.disclaimerAccepted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get llmProvider => $composableBuilder(
    column: $table.llmProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get morningReminder => $composableBuilder(
    column: $table.morningReminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get eveningReminder => $composableBuilder(
    column: $table.eveningReminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get mealReminders => $composableBuilder(
    column: $table.mealReminders,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get trackMenstrualCycle => $composableBuilder(
    column: $table.trackMenstrualCycle,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get disclaimerAccepted => $composableBuilder(
    column: $table.disclaimerAccepted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get llmProvider => $composableBuilder(
    column: $table.llmProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get morningReminder => $composableBuilder(
    column: $table.morningReminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get eveningReminder => $composableBuilder(
    column: $table.eveningReminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get mealReminders => $composableBuilder(
    column: $table.mealReminders,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get trackMenstrualCycle => $composableBuilder(
    column: $table.trackMenstrualCycle,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get disclaimerAccepted => $composableBuilder(
    column: $table.disclaimerAccepted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onboardingComplete => $composableBuilder(
    column: $table.onboardingComplete,
    builder: (column) => column,
  );

  GeneratedColumn<String> get llmProvider => $composableBuilder(
    column: $table.llmProvider,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get morningReminder => $composableBuilder(
    column: $table.morningReminder,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get eveningReminder => $composableBuilder(
    column: $table.eveningReminder,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get mealReminders => $composableBuilder(
    column: $table.mealReminders,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get trackMenstrualCycle => $composableBuilder(
    column: $table.trackMenstrualCycle,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> disclaimerAccepted = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<String?> llmProvider = const Value.absent(),
                Value<bool> morningReminder = const Value.absent(),
                Value<bool> eveningReminder = const Value.absent(),
                Value<bool> mealReminders = const Value.absent(),
                Value<bool> trackMenstrualCycle = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                disclaimerAccepted: disclaimerAccepted,
                onboardingComplete: onboardingComplete,
                llmProvider: llmProvider,
                morningReminder: morningReminder,
                eveningReminder: eveningReminder,
                mealReminders: mealReminders,
                trackMenstrualCycle: trackMenstrualCycle,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> disclaimerAccepted = const Value.absent(),
                Value<bool> onboardingComplete = const Value.absent(),
                Value<String?> llmProvider = const Value.absent(),
                Value<bool> morningReminder = const Value.absent(),
                Value<bool> eveningReminder = const Value.absent(),
                Value<bool> mealReminders = const Value.absent(),
                Value<bool> trackMenstrualCycle = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                disclaimerAccepted: disclaimerAccepted,
                onboardingComplete: onboardingComplete,
                llmProvider: llmProvider,
                morningReminder: morningReminder,
                eveningReminder: eveningReminder,
                mealReminders: mealReminders,
                trackMenstrualCycle: trackMenstrualCycle,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MealsTableTableManager get meals =>
      $$MealsTableTableManager(_db, _db.meals);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$MealIngredientsTableTableManager get mealIngredients =>
      $$MealIngredientsTableTableManager(_db, _db.mealIngredients);
  $$ContextEntriesTableTableManager get contextEntries =>
      $$ContextEntriesTableTableManager(_db, _db.contextEntries);
  $$SymptomsTableTableManager get symptoms =>
      $$SymptomsTableTableManager(_db, _db.symptoms);
  $$ChallengesTableTableManager get challenges =>
      $$ChallengesTableTableManager(_db, _db.challenges);
  $$ChallengeDaysTableTableManager get challengeDays =>
      $$ChallengeDaysTableTableManager(_db, _db.challengeDays);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
