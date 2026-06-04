# Contributing to DDLManager

Thanks for considering a contribution. This project is early-stage, so the most
valuable contributions are focused, well-tested changes that move the local DDL
manager MVP forward.

## Before You Start

- Read `AGENTS.md` for AI-assisted contribution rules.
- Check existing issues and pull requests before starting work when the GitHub
  repository is available.
- Keep changes scoped to one coherent purpose.
- Avoid low-value cosmetic churn unless it is part of substantive work.

## Local Development

Install Flutter stable, then run:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

For iOS-specific changes, make sure Xcode is available:

```bash
xcodebuild -version
flutter devices
```

## Pull Requests

Use a clear semantic title, such as:

```text
feat: add deadline list
fix: handle empty deadline title
docs: update setup instructions
```

Every PR should include:

- what changed and why
- how the change was validated
- screenshots or screen recordings for visible UI changes when practical
- a note if AI assistance was used

Do not include local private files, generated build output, credentials, or
machine-specific configuration.

## Testing Expectations

- Run `dart format .`, `flutter analyze`, and `flutter test` for Dart/Flutter
  changes.
- Add or update tests for behavior changes.
- If a check cannot be run locally, explain why in the PR.

## Platform Scope

The app is iOS-first, with macOS and web scaffolds present. Android support is
planned for later, after Android SDK setup is complete.

