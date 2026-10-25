import 'dart:convert';
import 'dart:io';

import 'goal_client.dart';

GoalClient createGoalClient({required String apiKey}) =>
    _HttpGoalClient(apiKey);

class _HttpGoalClient implements GoalClient {
  _HttpGoalClient(this.apiKey);

  final String apiKey;

  @override
  Future<String> complete(String prompt) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(
        Uri.parse('https://api.x.ai/v1/chat/completions'),
      );
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $apiKey');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.write(
        jsonEncode({
          'model': 'grok-4.7',
          'stream': false,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are Grok, a calm shopping editor. '
                  'You only reply with the JSON object you were asked for.',
            },
            {'role': 'user', 'content': prompt},
          ],
        }),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Goal model returned ${response.statusCode}');
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const FormatException('Goal model reply was not an object');
      }
      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) {
        throw const FormatException('Goal model reply had no choices');
      }
      final message = choices.first;
      if (message is! Map) {
        throw const FormatException('Goal model choice was not an object');
      }
      final content = message['message'];
      if (content is! Map || content['content'] is! String) {
        throw const FormatException('Goal model content was missing');
      }
      return content['content'] as String;
    } finally {
      client.close(force: true);
    }
  }
}
