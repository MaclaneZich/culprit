import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analysis/analysis_service.dart';
import 'analysis/models.dart';
import 'data/db/database.dart';
import 'services/llm/llm_service.dart';
import 'services/photo_store.dart';

/// Overridden in tests with an in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsProvider = StreamProvider<AppSetting>(
  (ref) => ref.watch(databaseProvider).watchSettings(),
);

final mealsProvider = StreamProvider<List<MealWithIngredients>>(
  (ref) => ref.watch(databaseProvider).watchMealsWithIngredients(),
);

final symptomsProvider = StreamProvider<List<Symptom>>(
  (ref) => ref.watch(databaseProvider).watchSymptoms(),
);

final contextEntriesProvider = StreamProvider<List<ContextEntry>>(
  (ref) => ref.watch(databaseProvider).watchContextEntries(),
);

final ingredientsProvider = StreamProvider<List<Ingredient>>(
  (ref) => ref.watch(databaseProvider).watchIngredients(),
);

final challengesProvider = StreamProvider<List<Challenge>>(
  (ref) => ref.watch(databaseProvider).watchChallenges(),
);

final challengeDaysProvider = StreamProvider.family<List<ChallengeDay>, int>(
  (ref, challengeId) =>
      ref.watch(databaseProvider).watchChallengeDays(challengeId),
);

/// The ranked analysis, recomputed whenever the log changes. Pure Dart —
/// no network, no LLM. At personal-log scale this is effectively instant.
final analysisProvider = Provider<AsyncValue<AnalysisResult>>((ref) {
  final meals = ref.watch(mealsProvider);
  final symptoms = ref.watch(symptomsProvider);
  final context = ref.watch(contextEntriesProvider);

  if (meals.isLoading || symptoms.isLoading || context.isLoading) {
    return const AsyncValue.loading();
  }
  final error = meals.error ?? symptoms.error ?? context.error;
  if (error != null) {
    return AsyncValue.error(error, StackTrace.current);
  }

  return AsyncValue.data(
    const AnalysisService().analyze(
      meals: meals.requireValue,
      symptoms: symptoms.requireValue,
      contextEntries: context.requireValue,
    ),
  );
});

final photoStoreProvider = Provider<PhotoStore>((ref) => const PhotoStore());

final llmKeyStoreProvider = Provider<LlmKeyStore>((ref) => const LlmKeyStore());

/// Null when the user has not connected an API key: the app then runs fully
/// local with manual entry and on-device stats.
final llmServiceProvider = FutureProvider<LlmService?>((ref) async {
  final settings = await ref.watch(settingsProvider.future);
  final providerName = settings.llmProvider;
  if (providerName == null) return null;
  final provider = LlmProvider.values.asNameMap()[providerName];
  if (provider == null) return null;
  final key = await ref.watch(llmKeyStoreProvider).read();
  if (key == null || key.isEmpty) return null;
  return LlmService(provider: provider, apiKey: key);
});
