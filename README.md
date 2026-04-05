# Study Tracker Mobile

Study Tracker Mobile is a local-first Flutter application for focused study sessions, planning, and analytics. The app is designed around reliability-first behavior: real persisted data, explicit error visibility, and deterministic state transitions.

## Tech Stack

- Flutter (Material)
- Riverpod (state management + dependency injection)
- SQLite via `sqflite` (local persistence)
- `go_router` (shell routing)
- `fl_chart` (analytics charts)
- `shared_preferences` (lightweight app settings + timer snapshot)
- `flutter_local_notifications` (timer completion alerts)

## Architecture Overview

The codebase follows a feature-first structure with explicit layering per feature:

- `lib/core`: shared infrastructure (routing, theme, providers, services)
- `lib/features/*/application`: Riverpod notifiers and orchestration logic
- `lib/features/*/domain`: entities/models and repository interfaces/implementations
- `lib/features/*/presentation`: screens/widgets/providers

State is driven by `AsyncNotifier`/`Notifier` classes and surfaced through `AsyncValue` UI states. Persistence and side effects are injected through providers rather than hardcoded singletons.

## Build and Run

Prerequisites:

- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)
- Platform toolchains for your target (Android Studio/Xcode/etc.)

Install dependencies:

- `flutter pub get`

Generate localization outputs:

- `flutter gen-l10n`

Run app:

- `flutter run`

Run static analysis:

- `flutter analyze`

Run tests:

- `flutter test`

## Reliability Guardrails

- Home initialization failures are intentionally surfaced as `AsyncValue.error` (no silent mock fallback).
- Analytics and Daily Truth are based on persisted session data.
- Tests include explicit guards against surfaced async error widgets/text.

## Repository Notes

- The `/doc` folder includes architecture and phase history. Files `01_*` and `02_*` are archived historical snapshots as of Phase 11.
- The current operational truth is tracked in `doc/03_current_status.md`.
