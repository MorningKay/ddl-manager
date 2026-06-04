# DDLManager

DDLManager is an iOS-first Flutter app for managing deadlines. The project is
currently in bootstrap stage and is being kept ready for future macOS, web, and
Android support.

## Current Status

- Flutter app scaffolded with iOS, macOS, and web targets.
- Android target is deferred until the Android SDK is configured locally.
- The first product milestone is a small local deadline-management MVP.

## Development Setup

Install Flutter stable and verify your local toolchain:

```bash
flutter --version
flutter doctor
flutter pub get
```

For iOS work, also verify Xcode:

```bash
xcodebuild -version
flutter devices
```

## Common Commands

```bash
dart format .
flutter analyze
flutter test
```

Run the app:

```bash
flutter run
```

## Project Conventions

- Public AI-assisted contribution rules are in `AGENTS.md`.
- Contributor workflow details are in `CONTRIBUTING.md`.
- Keep the first milestone focused on local deadline management before cloud
  sync, account systems, or collaboration features.
- Keep iOS-specific behavior behind clear platform boundaries so other targets
  can be added later.

## Adding Android Later

After Android Studio and the Android SDK are installed, add Android support with:

```bash
flutter create --platforms=android .
```

