import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  static Future<void> register(String email, String password) => _guard(
    () =>
        _auth.createUserWithEmailAndPassword(email: email, password: password),
  );

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
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return;
      }
      throw const AuthFailure('Google sign-in failed. Please try again.');
    }
  });

  static Future<void> signOut() async {
    if (!kIsWeb && _googleReady != null) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
  }

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
