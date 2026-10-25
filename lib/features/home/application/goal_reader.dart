import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'goal_client.dart';
import 'goal_client_stub.dart' if (dart.library.io) 'goal_client_io.dart';
import 'intent_controller.dart';

/// A free-form goal turned into a ceiling, keywords and a trade-off note.
@immutable
class GoalReading {
  const GoalReading({
    required this.intent,
    required this.explanation,
    required this.fromModel,
  });

  final IntentQuery intent;
  final String explanation;

  /// True when a model wrote [explanation]. False is the on-device reading.
  final bool fromModel;
}

/// Reads a shopping goal. A model is used when an API key is compiled in
/// (`--dart-define=XAI_API_KEY=...`); otherwise the on-device parser runs,
/// so the app works with no network and no key.
abstract final class GoalReader {
  static const modelId = 'grok-4.7';

  static const _key = String.fromEnvironment('XAI_API_KEY');

  static GoalReading local(String input) {
    final intent = IntentQuery.parse(input);
    return GoalReading(
      intent: intent,
      explanation: _explain(intent),
      fromModel: false,
    );
  }

  /// Asks the model, then falls back to [local] if there is no key, the
  /// call fails, or the reply is not usable.
  static Future<GoalReading> read(
    String input, {
    GoalClient? client,
    String? apiKey,
  }) async {
    final fallback = local(input);
    final key = apiKey ?? _key;
    if (key.isEmpty && client == null) return fallback;
    try {
      final raw = await (client ?? createGoalClient(apiKey: key)).complete(
        _prompt(input),
      );
      final parsed = parseModelReply(raw, fallback: fallback.intent);
      if (parsed == null) return fallback;
      return parsed;
    } catch (error, stack) {
      developer.log(
        'Goal model unavailable, using the on-device reading',
        error: error,
        stackTrace: stack,
      );
      return fallback;
    }
  }

  /// Pulls a reading out of a model reply. Accepts raw JSON or a reply
  /// that wraps JSON in prose. Returns null when nothing usable is there.
  static GoalReading? parseModelReply(
    String raw, {
    required IntentQuery fallback,
  }) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw.substring(start, end + 1));
    } catch (_) {
      return null;
    }
    if (decoded is! Map) return null;
    final map = decoded.cast<Object?, Object?>();
    final explanation = map['explanation'];
    if (explanation is! String || explanation.trim().isEmpty) return null;
    final words = map['keywords'];
    final keywords = words is List
        ? words.whereType<String>().map((w) => w.toLowerCase()).toSet()
        : fallback.keywords;
    final budgetValue = map['budget'];
    final budget = budgetValue is num
        ? budgetValue.toDouble()
        : fallback.budget;
    return GoalReading(
      intent: IntentQuery(
        raw: fallback.raw,
        keywords: keywords.isEmpty ? fallback.keywords : keywords,
        budget: budget,
      ),
      explanation: explanation.trim(),
      fromModel: true,
    );
  }

  static String _prompt(String input) =>
      'The shopper wrote: "$input". '
      'Reply with JSON only, no markdown: '
      '{"keywords":["lowercase words"],"budget":number or null,'
      '"explanation":"two sentences on the trade-off of waiting, '
      'spending less, or buying the better-fitting item"}';

  static String _explain(IntentQuery intent) {
    final budget = intent.budget;
    final words = intent.keywords.isEmpty
        ? 'no specific words'
        : intent.keywords.join(', ');
    final ceiling = budget == null
        ? 'No price ceiling was stated, so fit and the monthly envelope decide.'
        : 'The ceiling is ₹${budget.round()}. '
              'A cheaper item leaves more of it, and a closer match may be '
              'worth more of it.';
    return 'Reading "$words" on this device. $ceiling '
        'The set below is the best combination under that ceiling, '
        'not only the single highest score.';
  }
}

class GoalExplanationController extends Notifier<GoalReading?> {
  @override
  GoalReading? build() => null;

  /// Shows the on-device reading at once, then replaces it if the model
  /// returns a clearer one. The intent updates with each reading.
  Future<void> explain(String input) async {
    final text = input.trim();
    if (text.isEmpty) {
      state = null;
      ref.read(intentProvider.notifier).clear();
      return;
    }
    final local = GoalReader.local(text);
    state = local;
    ref.read(intentProvider.notifier).apply(local.intent);
    final reading = await GoalReader.read(text);
    if (!ref.mounted) return;
    if (ref.read(intentProvider)?.raw != text) return;
    state = reading;
    ref.read(intentProvider.notifier).apply(reading.intent);
  }

  void clear() => state = null;
}

final goalExplanationProvider =
    NotifierProvider<GoalExplanationController, GoalReading?>(
      GoalExplanationController.new,
    );
