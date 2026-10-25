import 'package:clarion/features/auth/application/auth_service.dart';
import 'package:clarion/features/auth/presentation/sign_in_screen.dart';
import 'package:clarion/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  test('Firebase error codes map to plain-language messages', () {
    expect(
      AuthService.messageFor('invalid-credential'),
      'Email or password is incorrect.',
    );
    expect(
      AuthService.messageFor('wrong-password'),
      AuthService.messageFor('user-not-found'),
    );
    expect(
      AuthService.messageFor('email-already-in-use'),
      'An account already exists for that email.',
    );
    expect(
      AuthService.messageFor('some-new-code'),
      'Something went wrong. Please try again.',
    );
  });

  test(
    'a misconfigured Google sign-in says so; closing the picker does not',
    () {
      String? message(GoogleSignInExceptionCode code, [String? detail]) =>
          AuthService.googleMessageFor(code, detail);

      // An unregistered SHA-1 arrives as a "cancellation" from Credential
      // Manager; it must not be mistaken for the user backing out.
      expect(
        message(
          GoogleSignInExceptionCode.canceled,
          '[16] Account reauth failed.',
        ),
        AuthService.googleNotConfigured,
      );
      expect(
        message(GoogleSignInExceptionCode.clientConfigurationError),
        AuthService.googleNotConfigured,
      );
      expect(
        message(
          GoogleSignInExceptionCode.canceled,
          'activity is cancelled by the user.',
        ),
        isNull,
      );
      expect(message(GoogleSignInExceptionCode.interrupted), isNull);
      expect(
        message(
          GoogleSignInExceptionCode.unknownError,
          'No credential available',
        ),
        contains('No Google account'),
      );
      expect(
        message(GoogleSignInExceptionCode.unknownError),
        'Google sign-in failed. Please try again.',
      );
    },
  );

  Future<void> pumpSignIn(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(412, 915));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const ProviderScope(child: ClarionApp(home: SignInScreen())),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('sign-in validates input before calling Firebase', (
    tester,
  ) async {
    await pumpSignIn(tester);
    expect(find.text('Welcome back'), findsOneWidget);

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter your email and password.'), findsOneWidget);

    await tester.tap(find.text('Forgot password?'));
    await tester.pump();
    expect(find.text('Enter your email first.'), findsOneWidget);
  });

  testWidgets('sign-in switches to account creation', (tester) async {
    await pumpSignIn(tester);
    await tester.tap(find.text('Sign up'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Start deciding better'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Forgot password?'), findsNothing);
  });
}
