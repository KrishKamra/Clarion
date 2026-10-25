import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/db/app_database.dart';
import '../../../core/notifications/notification_service.dart';

/// The signed-in account, or `null` outside a session (and in widget tests).
///
/// `AuthGate` overrides this for each account's provider scope.
final currentUserProvider = Provider<User?>((ref) => null);

/// Thin wrapper over Firebase Auth. Every method throws [AuthFailure] with a
/// message fit to show the user; a dismissed Google picker returns quietly.
abstract final class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static Future<void>? _googleReady;

  static Future<void> signIn(String email, String password) => _guard(
    () => _auth.signInWithEmailAndPassword(email: email, password: password),
  );

  static Future<void> register(String email, String password) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await cred.user?.sendEmailVerification();
      });

  static Future<void> sendEmailVerification() => _guard(() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  });

  static Future<void> reloadUser() => _guard(() async {
    await _auth.currentUser?.reload();
  });

  static bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  static Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email));

  static Future<void> signInWithGoogle() => _guard(() async {
    // The web SDK runs its own popup; mobile goes through Credential Manager.
    if (kIsWeb) {
      await _auth.signInWithPopup(GoogleAuthProvider());
      return;
    }
    await (_googleReady ??= GoogleSignIn.instance.initialize());
    try {
      final account = await GoogleSignIn.instance.authenticate();
      await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: account.authentication.idToken),
      );
    } on GoogleSignInException catch (e) {
      // Also visible in the `flutter run` console, for the full detail.
      debugPrint('Google sign-in: ${e.code} - ${e.description}');
      final message = googleMessageFor(e.code, e.description);
      if (message != null) throw AuthFailure(message);
    }
  });

  /// Shown when this build's signing key isn't registered in Firebase.
  static const googleNotConfigured =
      'Google sign-in isn’t set up for this build of the app. Please sign '
      'in with email for now.';

  /// What to tell the user about a failed Google sign-in, or `null` when
  /// they simply closed the account picker.
  ///
  /// On Android, an unregistered SHA-1 doesn't arrive as a configuration
  /// error: Credential Manager reports it as a cancellation whose message
  /// is "[16] Account reauth failed.", so that case is told apart here
  /// instead of being dropped as if the user had backed out.
  @visibleForTesting
  static String? googleMessageFor(
    GoogleSignInExceptionCode code,
    String? description,
  ) {
    final detail = description?.toLowerCase() ?? '';
    return switch (code) {
      GoogleSignInExceptionCode.canceled
          when detail.contains('[16]') || detail.contains('reauth') =>
        googleNotConfigured,
      GoogleSignInExceptionCode.canceled ||
      GoogleSignInExceptionCode.interrupted => null,
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError =>
        googleNotConfigured,
      GoogleSignInExceptionCode.uiUnavailable =>
        'Google sign-in couldn’t open. Please try again.',
      _ when detail.contains('no credential') =>
        'No Google account is set up on this device. Add one in Settings, '
            'then try again.',
      _ => 'Google sign-in failed. Please try again.',
    };
  }

  static Future<void> signOut() async {
    // Reminders belong to this account; the next one must not see them.
    await NotificationService.cancelAll();
    if (!kIsWeb && _googleReady != null) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

  /// Permanently deletes the signed-in account, then everything this device
  /// holds for it: its SQLite data, its reminders and its saved settings.
  ///
  /// The Firebase account goes first. Firebase often refuses with
  /// `requires-recent-login`; when it does, nothing local has been touched,
  /// so the user keeps their data and can retry after signing in again.
  static Future<void> deleteAccount({AppDatabase? db}) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    await user.delete();

    await NotificationService.cancelAll();
    try {
      await db?.resetAll();
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys().where((k) => k.endsWith('_$uid'))) {
        await prefs.remove(key);
      }
      if (!kIsWeb && _googleReady != null) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (error) {
      // The account is already gone; leftovers here are harmless.
      debugPrint('Account deleted, but local cleanup failed: $error');
    }
  });

  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(messageFor(e.code));
    }
  }

  /// Plain-language copy for Firebase Auth error codes.
  static String messageFor(String code) => switch (code) {
    'invalid-email' => 'That email address doesn’t look right.',
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => 'Email or password is incorrect.',
    'email-already-in-use' => 'An account already exists for that email.',
    'weak-password' => 'Use a password of at least 6 characters.',
    'user-disabled' => 'This account has been disabled.',
    'too-many-requests' => 'Too many attempts. Try again in a few minutes.',
    'network-request-failed' => 'No connection. Check your network.',
    'operation-not-allowed' => 'This sign-in method isn’t enabled yet.',
    'account-exists-with-different-credential' =>
      'This email already has an account. Sign in with email and password.',
    'requires-recent-login' => 'For security, please sign out and sign in again before deleting your account.',
    _ => 'Something went wrong. Please try again.',
  };
}

/// An authentication error with a user-facing [message].
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
