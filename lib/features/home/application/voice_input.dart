import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android speech recognition. Returns the words the person said, or null
/// when voice input isn't available or they cancel.
abstract final class VoiceInput {
  static const _channel = MethodChannel('com.example.clarion/home_widget');

  static Future<String?> listen() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      final words = await _channel.invokeMethod<String>('listen');
      final trimmed = words?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      return trimmed;
    } catch (error, stack) {
      developer.log('Voice input unavailable', error: error, stackTrace: stack);
      return null;
    }
  }
}
