# Codex Working Guide for Solrun

This file is the first context Codex should read before changing this repo.
It summarizes the current project contract and points to deeper docs.

## Project Intent

Solrun is a Flutter running tracker for Android and iOS. It is local-first,
ad-free, and has no account system, backend service, social graph, analytics
SDK, heart-rate support, or Bluetooth device integration.

The app is branded as Solrun in UI/docs. The Dart package remains `run_pure`
and the Android package remains `com.runpure.run_pure`.

## Fast Context

- Canonical project overview: `README.md`
- Long AI-agent context: `CLAUDE.md`
- Codex short context: `docs/codex-project-context.md`
- Android background GPS history: `docs/后台保活优化记录.md`
- AI audience design: `docs/runpure观众系统设计.md`
- AI audience implementation plan/status: `docs/runpure观众系统开发计划.md`

## Architecture

Use the existing feature-first layout:

- `lib/app/` contains routing, shell, theme, locale, and app-level providers.
- `lib/data/` contains Drift database definitions, generated code, DAO
  providers, and shared DAO classes.
- `lib/features/<feature>/data` is for infrastructure/service adapters.
- `lib/features/<feature>/domain` is for pure business logic.
- `lib/features/<feature>/presentation` is for UI, notifiers, and state.
- `lib/shared/` contains reusable widgets, utilities, and services.

Prefer extending existing modules over adding new top-level directories.

## Hard Boundaries

- Do not add backend, account, ads, analytics, social, heart-rate, Bluetooth, or
  wearable-device features unless the product direction is explicitly changed.
- Do not create a second `AppDatabase()` instance in app code. Use
  `databaseProvider`; multiple database connections have caused SQLITE_BUSY.
- Do not replace Android background tracking with a pure Flutter/geolocator
  foreground-service path. The verified solution is the native Kotlin
  `RunLocationService` plus Dart `EventChannel`.
- Do not store API keys in plain preferences. Use the existing secure-storage
  path under the LLM/AI settings code.
- Do not store converted GCJ-02 coordinates in the database. Persist WGS-84 and
  convert only for AMap rendering.
- Do not make online elevation correction mandatory. Elevation gain should use
  Open-Meteo DEM when available and fall back to conservative GPS altitude
  estimation when offline, timed out, or rate-limited.
- Do not add dependencies by default. Reuse current Flutter/Dart packages and
  existing utilities first.

## High-Risk Areas

Treat these as behavior-sensitive and verify carefully:

- `lib/features/tracking/`: running state machine, GPS handling, pause/resume,
  checkpoints, elevation finalization, persistence, TTS, and result finalization.
- `android/app/src/main/kotlin/com/runpure/run_pure/RunLocationService.kt`:
  Android true-background GPS on Honor/Huawei-style ROMs.
- `lib/data/database.dart` and `lib/data/daos/`: migrations, indexes, and
  cascade deletes.
- `lib/shared/services/llm/` and `lib/features/audience/`: AI provider behavior,
  streaming, timeouts, and failure fallback.
- `lib/l10n/`: ARB changes require generated localization files to stay in sync.

## Development Rules

- Keep changes small and reversible.
- Preserve current visual language unless the task is explicitly a redesign.
- Prefer pure-domain changes plus tests for algorithmic behavior.
- When modifying database schema, update `schemaVersion`, migrations, generated
  Drift files, and tests where applicable.
- When modifying ARB localization, run `flutter gen-l10n` and commit generated
  `app_localizations*.dart` updates.
- When changing generated Drift inputs, run:
  `dart run build_runner build --delete-conflicting-outputs`.
- When touching tracking, do not rely on emulator-only validation. Real-device
  validation is required for GPS/background behavior.

## Verification Ladder

Use the lightest verification that proves the change:

- Pure Dart/domain logic: targeted `flutter test test/path/to_test.dart`.
- UI/state/provider changes: targeted tests when present, then `flutter analyze`.
- Database/DAO changes: targeted DAO tests or full `flutter test`, plus codegen.
- Tracking/background GPS changes: static checks plus real-device manual test.
- Android native service changes: `flutter build apk` and real-device manual test.

Known environment note: `flutter test` may hang during dependency resolution on
this host. If that happens, report it as an environment blocker and run narrower
checks if possible.

## Real-Device Test Checklist

For tracking-related work, ask the human tester to verify on the target phone:

- Start run, wait for GPS lock, record distance and pace.
- Lock screen for several minutes and confirm distance still increases.
- Return to foreground and confirm no distance jump or frozen GPS.
- Pause/resume and auto-pause behavior if touched.
- End run and verify saved route, splits, city/weather, achievements, and
  elevation gain, achievements, and audience unlock checks if relevant.
- For elevation changes, test with network available and unavailable. The
  network path should use DEM correction; the offline path should still save the
  run with GPS-estimated elevation.
- Start a second run without force-killing the app.

## Commit Guidance

If asked to commit, use the Lore Commit Protocol from the workspace guidance:
intent line first, then concise context and useful trailers such as `Tested:`,
`Not-tested:`, `Constraint:`, `Rejected:`, `Confidence:`, and `Scope-risk:`.
