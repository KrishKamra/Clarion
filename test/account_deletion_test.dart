import 'package:clarion/features/auth/application/auth_service.dart';
import 'package:clarion/features/profile/presentation/widgets/delete_account_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService deleteAccount', () {
    test('maps requires-recent-login error message correctly', () {
      final message = AuthService.messageFor('requires-recent-login');
      expect(
        message,
        'For security, please sign out and sign in again before deleting your account.',
      );
    });
  });

  group('DeleteAccountSheet Widget', () {
    testWidgets('renders warning messages and confirmation buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDeleteAccountSheet(context),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Account'), findsOneWidget);
      expect(
        find.text('This action is permanent and cannot be undone.'),
        findsOneWidget,
      );
      expect(find.text('Delete account permanently'), findsOneWidget);
      expect(find.text('Keep my account'), findsOneWidget);

      await tester.tap(find.text('Keep my account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Account'), findsNothing);
    });
  });
}
