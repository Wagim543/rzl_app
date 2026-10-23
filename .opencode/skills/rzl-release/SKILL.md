---
name: RZL Release
description: Load when building an APK or AAB, setting up Android signing or a keystore, bumping the app version, installing on a physical device for a demo or UAT, or preparing release and defense-day artifacts.
---

# RZL — Android Release

Target: a signed APK installed on physical devices for UAT and defense. Play Store
submission is optional and not required by the study.

## Versioning

`pubspec.yaml`:

```yaml
version: 1.0.0+1
#        ^     ^
#        |     build number (versionCode, must increase)
#        name  (versionName, human facing)
```

Rules:
- Bump the build number on **every** build installed on a device. Otherwise Android refuses
  the update or the panel compares two different builds under the same version.
- Tag releases: `v1.0.0` after QA, `v1.0.0-defense` for the final build.
- Record the version in every QA run file (`docs/qa/results/run-NN.md`). A results table
  without a build identifier is not evidence.

## One-time signing setup

```powershell
keytool -genkey -v -keystore rzl-release.jks `
  -keyalg RSA -keysize 2048 -validity 10000 -alias rzl
```

Create `android/key.properties` (**gitignored, never committed**):

```properties
storePassword=...
keyPassword=...
keyAlias=rzl
storeFile=../rzl-release.jks
```

`android/app/build.gradle.kts`:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
        }
    }
}
```

`.gitignore` must contain:

```
android/key.properties
*.jks
*.keystore
env.json
```

**Losing the keystore loses the ability to update the app.** Keep two copies: the team's
shared drive and one physical USB. This is a real capstone failure that happens every year.

## Building

```bash
# Development build with env
flutter build apk --release --dart-define-from-file=env.json

# Split per ABI (smaller APKs, better for weak devices)
flutter build apk --release --dart-define-from-file=env.json --split-per-abi

# Play Store bundle (only if submitting)
flutter build appbundle --release --dart-define-from-file=env.json
```

Output:
- `build/app/outputs/flutter-apk/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

`env.json` must exist at the repo root:

```json
{
  "SUPABASE_URL": "https://<project>.supabase.co",
  "SUPABASE_ANON_KEY": "<anon key>",
  "EMBEDDING_FN_URL": "https://<project>.supabase.co/functions/v1"
}
```

Assert non-empty at startup (see `rzl-flutter/references/structure.md`). A release build with
empty `--dart-define` values is the most common "works in debug, blank in release" bug.

## Pre-release checklist

- [ ] `flutter analyze` clean
- [ ] `dart format .` applied
- [ ] `flutter test` passing
- [ ] Full QA matrix executed for this build
- [ ] App opens **as a guest** with real events (no login wall)
- [ ] Login → bookmark → RSVP → comment → logout → guest feed still works
- [ ] Airplane mode: retry affordance, no infinite spinner
- [ ] Icon and app name correct (not "rzl_app")
- [ ] Splash screen shows the app name, not the Flutter logo
- [ ] Version code incremented
- [ ] Installed from the APK file, **not** via `flutter run`, on at least 2 devices
- [ ] Tested on one Android version older than the dev phone

## Installing for UAT / defense

```bash
adb devices
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Or copy the APK to the phone and open it (requires "install unknown apps" permission —
enable it beforehand, not in front of the panel).

If the same package is already installed with a different signature, uninstall first:

```bash
adb uninstall com.example.rzl_app
```

Set a real application ID before any distribution — `com.example.*` looks unfinished:

```kotlin
// android/app/build.gradle.kts
defaultConfig {
    applicationId = "ph.edu.urs.rzl"
    minSdk = 24
    targetSdk = flutter.targetSdkVersion
}
```

## Demo-day kit

Bring all of these on a USB and in cloud storage:

| Item | Why |
|---|---|
| `app-release.apk` | Reinstall if a phone is wiped |
| Screenshots of every Chapter 4 table | Laptop failure insurance |
| Test matrix exported to PDF with the run date | Panel will ask |
| `rzl-release.jks` + `key.properties` | Only if you must rebuild on site |
| Mobile hotspot | Venue Wi-Fi is unreliable; this is why FR-33 exists |
| One device with the app already installed and logged in | Saves setup time |

Have a **guest-mode** demo path rehearsed first. It is the first thing a panel asks for, and
it is the one path that does not depend on credentials.

## Anti-patterns

| Don't | Why |
|---|---|
| Commit `key.properties` or `*.jks` | Credential leak; also breaks the "no secrets in source" rule |
| Demo with `flutter run` on your laptop | It is not the artifact you are submitting |
| Ship `com.example.*` | Reads as unfinished |
| Same build number on every install | Phones refuse updates; results become unattributable |
| Release build with empty `--dart-define` | Blank app, no error message |
| Rely on emulator only | Performance and permission behaviour differ, and the panel will use a phone |
