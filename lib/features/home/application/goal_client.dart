/// Something that can complete one goal-reading prompt.
abstract class GoalClient {
  Future<String> complete(String prompt);
}
