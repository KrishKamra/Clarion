import 'goal_client.dart';

GoalClient createGoalClient({required String apiKey}) => _Unavailable(apiKey);

class _Unavailable implements GoalClient {
  _Unavailable(this.apiKey);
  final String apiKey;

  @override
  Future<String> complete(String prompt) {
    throw UnsupportedError('Goal model needs a device with dart:io');
  }
}
