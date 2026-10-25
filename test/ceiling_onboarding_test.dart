import 'package:clarion/features/profile/application/ceiling_onboarding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('each account is prompted for its ceiling only once', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await CeilingOnboarding.isDone('alice'), isFalse);

    await CeilingOnboarding.markDone('alice');
    expect(await CeilingOnboarding.isDone('alice'), isTrue);

    // Another account on the same device is still new.
    expect(await CeilingOnboarding.isDone('bob'), isFalse);
  });
}
