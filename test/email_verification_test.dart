import 'package:clarion/features/auth/application/auth_service.dart';
import 'package:clarion/features/profile/presentation/widgets/email_verification_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockUser extends Fake implements User {
  MockUser({required this.emailVerified, required this.email});

  @override
  final bool emailVerified;

  @override
  final String? email;
}

void main() {
  group('isEmailVerifiedProvider', () {
    test('returns false when no user is signed in', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(isEmailVerifiedProvider), isFalse);
    });

    test('returns true when current user is verified', () {
      final container = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(
            MockUser(emailVerified: true, email: 'user@example.com'),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(isEmailVerifiedProvider), isTrue);
    });
  });

  group('EmailVerificationCard', () {
    testWidgets('renders unverified state with action buttons', (tester) async {
      final user = MockUser(emailVerified: false, email: 'test@clarion.app');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EmailVerificationCard(user: user),
              ),
            ),
          ),
        ),
      );

      expect(find.text('EMAIL VERIFICATION'), findsOneWidget);
      expect(find.text('Unverified'), findsOneWidget);
      expect(find.text('Resend email'), findsOneWidget);
      expect(find.text('I’ve verified'), findsOneWidget);
    });

    testWidgets('renders verified state with confirmed badge', (tester) async {
      final user = MockUser(emailVerified: true, email: 'verified@clarion.app');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EmailVerificationCard(user: user),
              ),
            ),
          ),
        ),
      );

      expect(find.text('EMAIL VERIFICATION'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Resend email'), findsNothing);
    });
  });
}
