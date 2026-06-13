# DDLManager

DDLManager is a Flutter app for managing Deadlines locally. It is currently an
early MVP focused on fast capture, clear time pressure, and lightweight
organization with tags.

## Features

- Create, edit, complete, and delete Deadline items.
- Store title, notes, priority, optional Deadline time, completion state, and
  multiple tags.
- Show active and closed Deadlines in separate tabs.
- Sort dated items by Deadline time and keep date-unannounced items grouped
  separately.
- Display remaining time and a countdown pressure bar for dated items.
- Filter the list by tags; selecting multiple tags shows items that contain all
  selected tags.
- Maintain user-managed quick tags in the editor. Quick tags start empty; adding
  a typed tag saves it as a quick tag, and unwanted quick tags can be deleted.
- Persist data locally with Drift/SQLite on native targets.
- Keep web runnable with an in-memory fallback for the current session.

## Platform Status

- iOS: primary target for the first MVP.
- macOS: scaffolded and usable for local desktop testing.
- Web: builds and runs with in-memory data only.
- Android: scaffolded, but local builds may require Android licenses and SQLite
  native-asset download/network setup.

## Development Setup

Use Flutter stable:

```bash
flutter --version
flutter doctor
flutter pub get
```

For iOS/macOS work:

```bash
xcodebuild -version
flutter devices
```

For Android work, after installing Android Studio and the SDK:

```bash
flutter doctor --android-licenses
flutter devices
```

## Common Commands

Regenerate Drift code after schema changes:

```bash
dart run build_runner build
```

Format, analyze, and test:

```bash
dart format .
flutter analyze
flutter test
```

Run the app:

```bash
flutter run
```

Build smoke checks:

```bash
flutter build web
flutter build ios --simulator --no-codesign
flutter build macos
flutter build apk --debug
```

## Project Conventions

- Public AI-assisted contribution rules are in `AGENTS.md`.
- Contributor workflow details are in `CONTRIBUTING.md`.
- Keep local-only notes and machine-specific context out of commits.
- Keep the first milestone focused on local Deadline management before cloud
  sync, account systems, notifications, or collaboration features.
- Keep platform-specific behavior behind explicit services or adapters so the
  app remains ready for multi-platform expansion.

## Current Limitations

- Web data is not persisted after refresh.
- Language selection is currently in-session only.
- Notifications, calendar views, cloud sync, accounts, and recurring Deadlines
  are not part of the first MVP.
- Android debug builds can fail if `package:sqlite3` cannot download its native
  Android asset in the local environment.
