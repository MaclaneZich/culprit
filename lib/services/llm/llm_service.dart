import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../analysis/models.dart';
import 'prompts.dart';

/// The only network surface in Culprit: the user's own opt-in LLM API.
///
/// Load-bearing design rule (see ARCHITECTURE.md): the model never sees the
/// raw log. It gets a single photo (to pre-fill an ingredient list the user
/// then confirms) or the already-computed statistics (to narrate). If no key
/// is configured, everything in the app works without this file.
enum LlmProvider {
  anthropic('Anthropic', 'claude-opus-4-8'),
  openai('OpenAI', 'gpt-4o');

  const LlmProvider(this.label, this.defaultModel);
  final String label;
  final String defaultModel;
}

class IngredientGuess {
  const IngredientGuess({required this.name, required this.hidden});

  final String name;

  /// True when the model flagged this as a commonly-hidden component
  /// (butter, garlic, cream...) rather than something visible in the photo.
  final bool hidden;
}

class LlmKeyStore {
  const LlmKeyStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  static const _keyName = 'llm_api_key';

  Future<String?> read() => _storage.read(key: _keyName);
  Future<void> write(String key) => _storage.write(key: _keyName, value: key);
  Future<void> delete() => _storage.delete(key: _keyName);
}

class LlmService {
  LlmService({required this.provider, required this.apiKey, http.Client? client})
      : _http = client ?? http.Client();

  final LlmProvider provider;
  final String apiKey;
  final http.Client _http;

  /// Vision-assisted pre-fill. Returns guesses the capture screen shows as
  /// unconfirmed chips; nothing enters the log until the user confirms.
  Future<List<IngredientGuess>> guessIngredients(File photo) async {
    final bytes = await photo.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mediaType =
        photo.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

    final text = switch (provider) {
      LlmProvider.anthropic => await _anthropic(
          system: Prompts.ingredientGuess,
          content: [
            {
              'type': 'image',
              'source': {
                'type': 'base64',
                'media_type': mediaType,
                'data': base64Image,
              },
            },
            {'type': 'text', 'text': 'Identify the meal components.'},
          ],
        ),
      LlmProvider.openai => await _openai(
          system: Prompts.ingredientGuess,
          content: [
            {
              'type': 'image_url',
              'image_url': {'url': 'data:$mediaType;base64,$base64Image'},
            },
            {'type': 'text', 'text': 'Identify the meal components.'},
          ],
        ),
    };
    return _parseGuesses(text);
  }

  /// Narrates the already-computed ranking. The prompt forbids inventing
  /// patterns; the numbers passed in are the model's entire world.
  Future<String> narrateInsights(AnalysisResult result) async {
    final grounded = _groundedSummary(result);
    switch (provider) {
      case LlmProvider.anthropic:
        return _anthropic(
          system: Prompts.insightNarration,
          content: [
            {'type': 'text', 'text': grounded},
          ],
        );
      case LlmProvider.openai:
        return _openai(
          system: Prompts.insightNarration,
          content: [
            {'type': 'text', 'text': grounded},
          ],
        );
    }
  }

  /// The exact text handed to the model: computed statistics only, no meals,
  /// no dates, no notes. Kept as a method so tests can pin its contents.
  static String _groundedSummary(AnalysisResult result) {
    final buffer = StringBuffer()
      ..writeln('Pre-computed association statistics from a personal GI log.')
      ..writeln('Logging: ${result.completeness.loggedDays} days with meals, '
          '${result.completeness.totalMeals} meals, '
          '${result.completeness.totalSymptoms} symptom episodes.')
      ..writeln('Top candidates (association score = shrunk rate ÷ base rate; '
          '1.0 means no different from any meal):');
    for (final candidate in result.candidates.take(5)) {
      final best = candidate.bestWindow;
      buffer.writeln(
        '- ${candidate.displayName} (${candidate.kind.name}): '
        'eaten ${candidate.totalExposures.toStringAsFixed(0)} times; in the '
        '${best.window.label} window symptoms followed '
        '${best.followed.toStringAsFixed(0)} times '
        '(rate ${(best.observedRate * 100).toStringAsFixed(0)}% vs base '
        '${(best.baseRate * 100).toStringAsFixed(0)}%); '
        'score ${candidate.score.toStringAsFixed(2)}; '
        'evidence ${candidate.strength.name}.',
      );
    }
    for (final factor in result.dayFactors.take(3)) {
      buffer.writeln(
        '- ${factor.displayName} (day-level factor): present '
        '${factor.factorDays} days; symptomatic on '
        '${factor.symptomaticFactorDays} of them '
        '(${(factor.observedRate * 100).toStringAsFixed(0)}% vs base '
        '${(factor.baseRate * 100).toStringAsFixed(0)}%).',
      );
    }
    return buffer.toString();
  }

  Future<String> _anthropic({
    required String system,
    required List<Map<String, Object?>> content,
  }) async {
    final response = await _http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': provider.defaultModel,
        'max_tokens': 1024,
        'system': system,
        'messages': [
          {'role': 'user', 'content': content},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw LlmException(_apiError(response));
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final blocks = (json['content'] as List).cast<Map<String, dynamic>>();
    return blocks
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String)
        .join();
  }

  Future<String> _openai({
    required String system,
    required List<Map<String, Object?>> content,
  }) async {
    final response = await _http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': provider.defaultModel,
        'max_tokens': 1024,
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': content},
        ],
      }),
    );
    if (response.statusCode != 200) {
      throw LlmException(_apiError(response));
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = json['choices'] as List;
    return ((choices.first as Map)['message'] as Map)['content'] as String;
  }

  static String _apiError(http.Response response) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final error = json['error'];
      if (error is Map && error['message'] is String) {
        return error['message'] as String;
      }
    } on FormatException {
      // fall through
    }
    return 'API error ${response.statusCode}';
  }

  static List<IngredientGuess> _parseGuesses(String text) {
    // Models occasionally wrap JSON in code fences despite instructions.
    var cleaned = text.trim();
    final fence = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(cleaned);
    if (fence != null) cleaned = fence.group(1)!;
    final start = cleaned.indexOf('[');
    final end = cleaned.lastIndexOf(']');
    if (start == -1 || end == -1 || end < start) return const [];
    try {
      final list = jsonDecode(cleaned.substring(start, end + 1)) as List;
      return [
        for (final item in list.whereType<Map>())
          if (item['name'] is String && (item['name'] as String).trim().isNotEmpty)
            IngredientGuess(
              name: (item['name'] as String).trim(),
              hidden: item['hidden'] == true,
            ),
      ];
    } on FormatException {
      return const [];
    }
  }
}

class LlmException implements Exception {
  const LlmException(this.message);

  final String message;

  @override
  String toString() => message;
}
