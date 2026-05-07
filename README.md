# Medicine Reminder

A Flutter medication reminder app that builds to an Android APK through GitHub Actions.

## Build the Android APK on GitHub

1. Push this repository to GitHub on the `main` branch.
2. Open the repository on GitHub.
3. Go to **Actions**.
4. Select **Build Android APK**.
5. Click **Run workflow**.
6. After the workflow finishes, download the `medicine-reminder-release-apk` artifact.

The APK inside the artifact is named:

```text
medicine-reminder-release.apk
```

The workflow also runs automatically on pushes and pull requests to `main`.

## Local Build

```sh
flutter pub get
flutter test
flutter build apk --release
```

The local APK output is created at:

```text
build/app/outputs/flutter-apk/app-release.apk
```
