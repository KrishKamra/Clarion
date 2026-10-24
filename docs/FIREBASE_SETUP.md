# Firebase setup

Clarion signs people in with Firebase Authentication (email/password and Google), using the Firebase project **`clarion-e08f0`**. The Android app is registered as `com.example.clarion`, which is fine because Clarion isn't published to the Play Store.

The generated config is committed (`lib/firebase_options.dart`, `android/app/google-services.json`, `firebase.json`), so after `flutter pub get` the app builds and **email sign-in works for everyone**.

## Teammates: enabling Google sign-in on your machine

Google sign-in on Android only works for builds signed with a key that's registered in Firebase. Every computer has its own debug key, so each teammate registers theirs once:

1. Print your debug key's fingerprints. In PowerShell:
   ```powershell
   keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
   ```
   Copy the `SHA1:` and `SHA256:` values.
2. Ask a project owner to add them in the Firebase console: click the **gear icon → Project settings → General → Your apps → com.example.clarion → Add fingerprint**, once for each value. You can do it yourself if you have edit access to the project.
3. Download the updated **google-services.json** from the same page, replace `android/app/google-services.json` with it and commit it.

Test Google sign-in on a real device, or on an emulator image with "Google Play" in its name and a Google account added.

## Reconfiguring from scratch

Only needed for a new Firebase project or new platforms. It overwrites the committed config files.

```powershell
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure
```

In the Firebase console, **Authentication → Sign-in method** must have **Email/Password** and **Google** enabled. Enable Google *before* downloading `google-services.json`, or the file won't contain the client Google sign-in needs (its `oauth_client` list will be empty).

## How access works

- **Authentication:** nothing in the app shows until Firebase reports a signed-in user (`AuthGate` in `lib/main.dart`).
- **Authorization:** all data is local. Each account gets its own SQLite file (`clarion_<uid>.db`) and its own provider scope, so people sharing a device never see each other's cart, holds, budget or watchlist. Data from before sign-in (`clarion.db`) isn't migrated.
- **Not set up yet:** server-side data (Firestore) and its security rules, and roles such as admin via custom claims.

The committed config files identify the project but contain no secrets. Access is enforced by Firebase Auth, not by keeping these values hidden.
