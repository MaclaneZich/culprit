import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/enums.dart';
import 'converters.dart';
import 'seed_ingredients.dart';

part 'database.g.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get portionSize => textEnum<PortionSize>()();
  TextColumn get source => textEnum<MealSource>()();
}

class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get canonicalName => text().unique()();
  TextColumn get triggerTags =>
      text().map(const TriggerTagSetConverter()).withDefault(const Constant(''))();
}

class MealIngredients extends Table {
  IntColumn get mealId =>
      integer().references(Meals, #id, onDelete: KeyAction.cascade)();
  IntColumn get ingredientId =>
      integer().references(Ingredients, #id, onDelete: KeyAction.cascade)();
  TextColumn get confidence => textEnum<IngredientConfidence>()();

  @override
  Set<Column> get primaryKey => {mealId, ingredientId};
}

class ContextEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get type => textEnum<ContextType>()();
  RealColumn get value => real()();
}

class Symptoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get types => text().map(const SymptomTypeSetConverter())();
  IntColumn get severity => integer()(); // 1-5
  /// Derived from the last logged meal at entry time, but user-editable,
  /// because "20 minutes after eggs" and "3 hours after eggs" implicate
  /// different mechanisms.
  IntColumn get minutesSinceLastMeal => integer().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get coincidentFactors =>
      text().map(const StringListConverter()).withDefault(const Constant(''))();
}

class Challenges extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Display label for the candidate under test (ingredient name or tag).
  TextColumn get title => text()();
  IntColumn get ingredientId =>
      integer().nullable().references(Ingredients, #id)();
  TextColumn get tag => textEnum<TriggerTag>().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get status => textEnum<ChallengeStatus>()();
  BoolColumn get blinded => boolean().withDefault(const Constant(false))();
  TextColumn get outcome => textEnum<ChallengeOutcome>().nullable()();
  TextColumn get resultNote => text().nullable()();
}

class ChallengeDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get challengeId =>
      integer().references(Challenges, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayIndex => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get kind => textEnum<ChallengeDayKind>()();

  /// Did the user follow the day's instruction (eat / avoid as scheduled)?
  BoolColumn get adhered => boolean().nullable()();

  /// Worst symptom severity that day; 0 means symptom-free. Null = not logged.
  IntColumn get maxSeverity => integer().nullable()();
  TextColumn get note => text().nullable()();
}

class AppSettings extends Table {
  /// Single-row table, id is always 1.
  IntColumn get id => integer()();
  BoolColumn get disclaimerAccepted =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get onboardingComplete =>
      boolean().withDefault(const Constant(false))();

  /// 'anthropic' or 'openai'. The key itself lives in the iOS keychain via
  /// flutter_secure_storage, never in this database.
  TextColumn get llmProvider => text().nullable()();
  BoolColumn get morningReminder => boolean().withDefault(const Constant(true))();
  BoolColumn get eveningReminder => boolean().withDefault(const Constant(true))();
  BoolColumn get mealReminders => boolean().withDefault(const Constant(false))();
  BoolColumn get trackMenstrualCycle =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Joined models
// ---------------------------------------------------------------------------

class MealIngredientDetail {
  const MealIngredientDetail({
    required this.ingredient,
    required this.confidence,
  });

  final Ingredient ingredient;
  final IngredientConfidence confidence;
}

class MealWithIngredients {
  const MealWithIngredients({required this.meal, required this.ingredients});

  final Meal meal;
  final List<MealIngredientDetail> ingredients;

  Set<TriggerTag> get allTags =>
      ingredients.expand((i) => i.ingredient.triggerTags).toSet();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [
  Meals,
  Ingredients,
  MealIngredients,
  ContextEntries,
  Symptoms,
  Challenges,
  ChallengeDays,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'culprit'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await batch((b) {
            b.insertAll(ingredients, [
              for (final seed in seedIngredients)
                IngredientsCompanion.insert(
                  canonicalName: seed.name,
                  triggerTags: Value(seed.tags),
                ),
            ]);
            b.insert(appSettings, const AppSettingsCompanion(id: Value(1)));
          });
        },
        onUpgrade: (m, from, to) async {
          // Never lose a user's log: additive migrations only. Add
          // `if (from < N)` steps here as the schema evolves.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // -- Meals ----------------------------------------------------------------

  /// Inserts a meal and its ingredient list in one transaction. Ingredient
  /// names are upserted by canonical name so the library grows with use.
  Future<int> insertMeal({
    required MealsCompanion meal,
    required List<({String name, Set<TriggerTag> tags, IngredientConfidence confidence})>
        ingredientEntries,
  }) {
    return transaction(() async {
      final mealId = await into(meals).insert(meal);
      for (final entry in ingredientEntries) {
        final ingredientId = await _upsertIngredient(entry.name, entry.tags);
        await into(mealIngredients).insert(
          MealIngredientsCompanion.insert(
            mealId: mealId,
            ingredientId: ingredientId,
            confidence: entry.confidence,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
      return mealId;
    });
  }

  Future<int> _upsertIngredient(String name, Set<TriggerTag> tags) async {
    final trimmed = name.trim();
    final existing = await (select(ingredients)
          ..where((i) => i.canonicalName.lower().equals(trimmed.toLowerCase())))
        .getSingleOrNull();
    if (existing != null) {
      if (tags.isNotEmpty && !existing.triggerTags.containsAll(tags)) {
        final merged = {...existing.triggerTags, ...tags};
        await (update(ingredients)..where((i) => i.id.equals(existing.id)))
            .write(IngredientsCompanion(triggerTags: Value(merged)));
      }
      return existing.id;
    }
    return into(ingredients).insert(
      IngredientsCompanion.insert(
        canonicalName: trimmed,
        triggerTags: Value(tags),
      ),
    );
  }

  Future<void> deleteMeal(int id) =>
      (delete(meals)..where((m) => m.id.equals(id))).go();

  Stream<List<MealWithIngredients>> watchMealsWithIngredients() {
    final query = select(meals).join([
      leftOuterJoin(mealIngredients, mealIngredients.mealId.equalsExp(meals.id)),
      leftOuterJoin(
          ingredients, ingredients.id.equalsExp(mealIngredients.ingredientId)),
    ])
      ..orderBy([OrderingTerm.desc(meals.timestamp)]);

    return query.watch().map((rows) {
      final byMeal = <int, MealWithIngredients>{};
      for (final row in rows) {
        final meal = row.readTable(meals);
        final entry = byMeal.putIfAbsent(
          meal.id,
          () => MealWithIngredients(meal: meal, ingredients: []),
        );
        final ingredient = row.readTableOrNull(ingredients);
        final link = row.readTableOrNull(mealIngredients);
        if (ingredient != null && link != null) {
          entry.ingredients.add(MealIngredientDetail(
            ingredient: ingredient,
            confidence: link.confidence,
          ));
        }
      }
      return byMeal.values.toList();
    });
  }

  Future<Meal?> lastMealBefore(DateTime time) => (select(meals)
        ..where((m) => m.timestamp.isSmallerOrEqualValue(time))
        ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
        ..limit(1))
      .getSingleOrNull();

  // -- Ingredients ----------------------------------------------------------

  Stream<List<Ingredient>> watchIngredients() => (select(ingredients)
        ..orderBy([(i) => OrderingTerm.asc(i.canonicalName)]))
      .watch();

  Future<void> updateIngredientTags(int id, Set<TriggerTag> tags) =>
      (update(ingredients)..where((i) => i.id.equals(id)))
          .write(IngredientsCompanion(triggerTags: Value(tags)));

  // -- Context --------------------------------------------------------------

  Future<void> upsertContextEntry(ContextEntriesCompanion entry) async {
    // One value per context type per calendar day; a re-log replaces it.
    final ts = entry.timestamp.value;
    final dayStart = DateTime(ts.year, ts.month, ts.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    await transaction(() async {
      await (delete(contextEntries)
            ..where((c) =>
                c.type.equalsValue(entry.type.value) &
                c.timestamp.isBiggerOrEqualValue(dayStart) &
                c.timestamp.isSmallerThanValue(dayEnd)))
          .go();
      await into(contextEntries).insert(entry);
    });
  }

  Stream<List<ContextEntry>> watchContextEntries() => (select(contextEntries)
        ..orderBy([(c) => OrderingTerm.desc(c.timestamp)]))
      .watch();

  Future<List<ContextEntry>> contextEntriesOn(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return (select(contextEntries)
          ..where((c) =>
              c.timestamp.isBiggerOrEqualValue(dayStart) &
              c.timestamp.isSmallerThanValue(dayEnd)))
        .get();
  }

  // -- Symptoms -------------------------------------------------------------

  Future<int> insertSymptom(SymptomsCompanion symptom) =>
      into(symptoms).insert(symptom);

  Future<void> deleteSymptom(int id) =>
      (delete(symptoms)..where((s) => s.id.equals(id))).go();

  Stream<List<Symptom>> watchSymptoms() => (select(symptoms)
        ..orderBy([(s) => OrderingTerm.desc(s.timestamp)]))
      .watch();

  // -- Challenges -----------------------------------------------------------

  Future<int> insertChallenge({
    required ChallengesCompanion challenge,
    required List<ChallengeDaysCompanion> days,
  }) {
    return transaction(() async {
      final id = await into(challenges).insert(challenge);
      for (final day in days) {
        await into(challengeDays)
            .insert(day.copyWith(challengeId: Value(id)));
      }
      return id;
    });
  }

  Stream<List<Challenge>> watchChallenges() => (select(challenges)
        ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
      .watch();

  Stream<List<ChallengeDay>> watchChallengeDays(int challengeId) =>
      (select(challengeDays)
            ..where((d) => d.challengeId.equals(challengeId))
            ..orderBy([(d) => OrderingTerm.asc(d.dayIndex)]))
          .watch();

  Future<List<ChallengeDay>> challengeDaysFor(int challengeId) =>
      (select(challengeDays)
            ..where((d) => d.challengeId.equals(challengeId))
            ..orderBy([(d) => OrderingTerm.asc(d.dayIndex)]))
          .get();

  Future<void> updateChallengeDay(int id, ChallengeDaysCompanion patch) =>
      (update(challengeDays)..where((d) => d.id.equals(id))).write(patch);

  Future<void> updateChallenge(int id, ChallengesCompanion patch) =>
      (update(challenges)..where((c) => c.id.equals(id))).write(patch);

  Future<void> deleteChallenge(int id) =>
      (delete(challenges)..where((c) => c.id.equals(id))).go();

  // -- Settings -------------------------------------------------------------

  Stream<AppSetting> watchSettings() =>
      (select(appSettings)..where((s) => s.id.equals(1))).watchSingle();

  Future<AppSetting> getSettings() =>
      (select(appSettings)..where((s) => s.id.equals(1))).getSingle();

  Future<void> updateSettings(AppSettingsCompanion patch) =>
      (update(appSettings)..where((s) => s.id.equals(1))).write(patch);

  // -- Export / delete ------------------------------------------------------

  Future<List<Meal>> allMeals() => (select(meals)
        ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]))
      .get();

  Future<List<MealWithIngredients>> allMealsWithIngredients() async {
    final allRows = await (select(meals)
          ..orderBy([(m) => OrderingTerm.asc(m.timestamp)]))
        .get();
    final links = await select(mealIngredients).get();
    final ingredientRows = await select(ingredients).get();
    final ingredientById = {for (final i in ingredientRows) i.id: i};
    final linksByMeal = <int, List<MealIngredientDetail>>{};
    for (final link in links) {
      final ingredient = ingredientById[link.ingredientId];
      if (ingredient == null) continue;
      linksByMeal.putIfAbsent(link.mealId, () => []).add(
            MealIngredientDetail(
              ingredient: ingredient,
              confidence: link.confidence,
            ),
          );
    }
    return [
      for (final meal in allRows)
        MealWithIngredients(
          meal: meal,
          ingredients: linksByMeal[meal.id] ?? const [],
        ),
    ];
  }

  Future<List<Symptom>> allSymptoms() => (select(symptoms)
        ..orderBy([(s) => OrderingTerm.asc(s.timestamp)]))
      .get();

  Future<List<ContextEntry>> allContextEntries() => (select(contextEntries)
        ..orderBy([(c) => OrderingTerm.asc(c.timestamp)]))
      .get();

  Future<List<Challenge>> allChallenges() => select(challenges).get();

  /// Full local wipe. Settings survive but disclaimers stay accepted;
  /// the ingredient library resets to the seed set.
  Future<void> deleteAllLogData() {
    return transaction(() async {
      await delete(challengeDays).go();
      await delete(challenges).go();
      await delete(mealIngredients).go();
      await delete(symptoms).go();
      await delete(contextEntries).go();
      await delete(meals).go();
      await delete(ingredients).go();
      await batch((b) {
        b.insertAll(ingredients, [
          for (final seed in seedIngredients)
            IngredientsCompanion.insert(
              canonicalName: seed.name,
              triggerTags: Value(seed.tags),
            ),
        ]);
      });
    });
  }
}
