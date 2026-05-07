# Firebase Setup

1. Install and login to the Firebase CLI.

```bash
npm install -g firebase-tools
firebase login
```

2. Install FlutterFire CLI.

```bash
dart pub global activate flutterfire_cli
```

3. Create/select a Firebase project, then configure this Flutter app.

```bash
flutterfire configure
```

Select Android, iOS, and Web if needed. This generates `lib/firebase_options.dart`
and native Firebase config files.

4. If `flutterfire configure` generates `firebase_options.dart`, update
`lib/main.dart`:

```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

5. In Firebase Console, enable:

- Authentication: Email/Password provider
- Firestore Database

6. Publish the rules from `firestore.rules`.

```bash
firebase deploy --only firestore:rules
```

7. Run the app.

```bash
flutter run
```

Android notification notes:

- Android 13+ requires notification permission, requested by the app.
- Exact alarms may require user/device policy approval on some Android versions.
