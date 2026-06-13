# Changelog

Notable changes to DDLManager are documented in this file.

This project follows semantic versioning once public releases begin.

## Unreleased

No unreleased changes yet.

## v0.1.0 - 2026-06-14

Initial public demo release.

- Add local Deadline creation, editing, completion toggling, deletion, and
  Drift-backed native persistence.
- Add Chinese-first Deadline board UI with active and closed tabs, countdown
  text, countdown pressure bars, priority color treatment, and support for
  date-unannounced items.
- Add multi-tag organization with compact item chips, user-managed quick tags,
  and all-selected-tags filtering.
- Add iOS, macOS, web, and Android project scaffolding.
- Add web in-memory fallback so the app remains runnable in browsers before web
  persistence is implemented.

## Release Process

1. Update this changelog by moving relevant `Unreleased` entries under the new
   version heading.
2. Run the relevant validation commands:

   ```bash
   dart format --set-exit-if-changed .
   flutter analyze
   flutter test
   flutter build web
   ```

3. Create an annotated tag:

   ```bash
   git tag -a v0.1.0 -m "v0.1.0"
   git push origin main
   git push origin v0.1.0
   ```

4. Draft a GitHub Release from the pushed tag and use GitHub's generated release
   notes as the starting point.
