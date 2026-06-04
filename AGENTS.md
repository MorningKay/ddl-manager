# Agent Instructions for DDLManager

> These instructions apply to AI-assisted contributions to DDLManager. A human
> contributor must review and own AI-assisted changes before submission.

## 1. Contribution Policy (Mandatory)

### Duplicate-work checks

Before proposing a PR, check whether the same work is already in progress when
the GitHub repository is available:

```bash
gh issue list --search "<short area keywords>"
gh pr list --state open --search "<short area keywords>"
```

- If an open PR already addresses the same issue, do not open a duplicate.
- If your approach is materially different, explain the difference in the issue
  or PR description.

### No low-value busywork PRs

Do not open one-off PRs for tiny isolated edits such as a single typo, cosmetic
style churn, or mechanical cleanup with no user-facing or maintenance value.
Small cleanups are acceptable when they are part of substantive work.

### Accountability

- Pure code-agent PRs are not accepted.
- The submitting human must understand the change end-to-end, review every
  changed line, and run relevant checks.
- PR descriptions for AI-assisted work should include why the work is not a
  duplicate, which checks were run, and a clear note that AI assistance was used.

### Fail-closed behavior

If the work is duplicate, trivial busywork, inadequately reviewed, or lacks
reasonable validation, do not proceed. Return a short explanation of what is
missing.

## 2. Development Workflow

### Environment setup

Use Flutter stable unless a task explicitly requires another channel.

```bash
flutter --version
flutter doctor
flutter pub get
```

For iOS-related work, also check the Apple toolchain when relevant:

```bash
xcodebuild -version
flutter devices
```

Do not assume Android support is available. Check `flutter doctor` before
starting Android-specific work.

### Format, lint, and test

For Dart and Flutter changes, run the smallest relevant checks first:

```bash
dart format .
flutter analyze
flutter test
```

Use focused tests for narrow changes. Run broader tests or build smoke checks
when a change touches app startup, routing, persistence, platform integration,
or shared behavior.

### Commit messages

Agents working in an interactive session should not create commits unless the
user explicitly asks. Contributors submitting PRs should use semantic commit
messages such as `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `deps:`,
`build:`, `chore:`, and `perf:`.

If AI assistance should be attributed, use commit trailers or the PR
description. Example:

```text
docs: update agent contribution rules

Co-authored-by: Codex
Signed-off-by: Your Name <your.email@example.com>
```

### Resolving agent reviews

Review comments from AI tools can be outdated or wrong. Verify suggestions
against the current code and project goals before applying them.

## 3. Flutter Engineering Guidelines

- Keep the first milestone focused on an iOS-first, local deadline-management
  MVP.
- Keep the architecture ready for Android, web, macOS, and desktop support.
- Prefer feature-first organization under `lib/features/` once application code
  is added.
- Keep domain logic separate from Flutter widgets when practical.
- Put platform-specific behavior behind explicit services or adapters.
- Avoid adding production dependencies until the existing Flutter SDK, package
  set, and project patterns have been checked.
- Prefer local persistence before account systems, cloud sync, or multi-user
  collaboration.
- Fail fast when required inputs, files, configs, credentials, dependencies, or
  platform assumptions are missing or invalid.

## 4. Domain-Specific Guides

No domain-specific guides are defined yet. If future areas need more than a few
non-obvious rules, create a focused guide under public project documentation and
link it here instead of expanding this file indefinitely.

Do not modify code in an area with a linked guide without reading and following
that guide first.

## 5. Editing These Instructions

- Keep this file under 200 lines.
- Add only project-wide, non-obvious rules that an agent is likely to miss.
- Do not copy upstream tool documentation; link to the source instead.
- Prefer one focused example over long explanatory prose.
- If a rule applies to only one feature area, put it in a domain-specific guide.

## Acknowledgements

This file's structure is adapted from the `verl-project/verl` agent
instructions and its guide for editing agent instructions.

