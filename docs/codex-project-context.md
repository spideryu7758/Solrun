# Codex Project Context

This is the short, task-oriented context for optimizing Solrun. It complements
`README.md`, `CLAUDE.md`, and the deeper documents in `docs/`.

## Product Shape

Solrun is a local-first running tracker. The core promise is reliable run
recording with private local data and no distractions. The app intentionally
does not include accounts, backend services, social features, ads, analytics,
heart-rate sensors, Bluetooth devices, or wearable-device integrations.

Main user flows:

- Home: weekly summary, training entry, start-run button.
- Tracking: permissions, GPS, timer, pace, elevation, TTS, checkpoints, audience
  shouts, and finalization.
- History: run list, details, map trajectory, replay, rename.
- Stats: monthly/yearly charts and aggregate metrics.
- Audience: AI shout history, favorite quotes, fan team, role gallery, interview.
- Share/export: share cards, GPX/CSV/Garmin/ZIP import/export.
- Settings: appearance, running options, map source/API key, personal info, data
  management, AI provider setup.

## Current Stack

- Flutter/Dart with Riverpod and GoRouter.
- Drift SQLite for local persistence.
- Android GPS: native Kotlin `RunLocationService` using Fused Location plus
  `LocationManager`, connected to Flutter through `MethodChannel`/`EventChannel`.
- Android cadence: native `TYPE_STEP_DETECTOR` through `step_stream`, guarded by
  `ACTIVITY_RECOGNITION`; unavailable sensors or denied permission fall back to
  GPS-speed auto-pause logic.
- Auto-pause: cadence first when available; otherwise GPS fallback combines
  speed, recent displacement, and accuracy instead of trusting `speed` alone.
- iOS GPS: geolocator `AppleSettings`.
- Map rendering: `flutter_map`, WGS-84 storage, GCJ-02 conversion only for AMap.
- LLM: provider abstraction supporting OpenAI-compatible providers and Anthropic.
- Localization: Flutter gen-l10n with Chinese and English ARB files.
- Elevation gain: Open-Meteo Elevation API DEM correction first, conservative
  GPS altitude fallback when the online service is unavailable.

## Code Map

- `lib/main.dart`: app initialization, foreground task init, training seed,
  crash-recovery prompt, update check.
- `lib/app/router.dart`: bottom-tab shell and full-screen routes.
- `lib/data/database.dart`: Drift schema, migrations, PRAGMAs, seed unlocks.
- `lib/data/providers.dart`: single database and DAO provider graph.
- `lib/features/tracking/presentation/tracking_notifier.dart`: run state machine.
- `lib/features/tracking/data/location_service.dart`: Dart-side platform GPS
  adapter.
- `lib/features/tracking/data/step_cadence_service.dart`: Android step detector
  stream and real-time cadence samples.
- `lib/features/tracking/domain/auto_pause_detector.dart`: cadence-first
  auto-pause with GPS speed/displacement/accuracy fallback.
- `android/app/src/main/kotlin/com/runpure/run_pure/RunLocationService.kt`:
  Android native background GPS service.
- `lib/features/tracking/domain/pace_calculator.dart`: distance, real-time pace,
  split pace, and GPS-gap tolerance.
- `lib/features/tracking/domain/elevation_calculator.dart`: elevation-gain
  filtering for GPS fallback and imported altitude values.
- `lib/features/tracking/domain/run_finalizer.dart`: city/weather, achievements,
  DEM elevation correction, audience unlock checks.
- `lib/shared/services/elevation_service.dart`: Open-Meteo DEM elevation lookup
  and route elevation-gain recalculation.
- `lib/features/audience/data/audience_engine.dart`: shout generation, LLM
  streaming, think-tag stripping, retry/fallback, persistence.
- `lib/shared/services/llm/`: provider abstractions and concrete adapters.
- `lib/shared/widgets/rp_components.dart`: shared visual building blocks.

## Important Invariants

- `databaseProvider` owns the app database. Avoid ad-hoc `AppDatabase()`.
- `RunSession` is created as incomplete at run start and completed at end.
- Route points are buffered and flushed in batches to avoid long-run memory
  growth.
- Checkpoints are written during active runs for crash recovery.
- Android native GPS service is intentionally independent of the Flutter engine.
- Auto-pause should prefer cadence when available, because GPS speed may drift
  while the runner is standing still. Without cadence, use combined GPS speed,
  recent displacement, and accuracy. It must still work without cadence sensor
  permission by falling back to GPS motion heuristics.
- Elevation correction is optional. Runs must still finish and save if the
  Open-Meteo DEM request fails, times out, or the phone is offline.
- AI failures must not block the core running flow.
- API keys belong in secure storage, not plaintext preferences.
- Database stores WGS-84 coordinates.
- Localization uses generated `S` accessors; user-facing strings should be
  localized unless the surrounding code intentionally uses a brand/slogan.

## Optimization Strategy

For feature optimization, first classify the change:

- UX-only: preserve existing component system and route structure.
- Algorithmic: isolate in `domain/` where possible and add targeted tests.
- Persistence: update migration/codegen/test path before UI polish.
- Tracking/GPS: make the smallest safe change and plan real-device verification.
- Cadence/auto-pause: verify Android runtime permission, live cadence display,
  stop-to-auto-pause, step-to-resume, and GPS-only fallback on a real phone.
- Elevation: prefer DEM correction for saved runs, but preserve GPS fallback and
  do not add API-key requirements.
- AI/audience: preserve silent degradation when unconfigured, offline, timed out,
  or rate-limited.

Prefer deletion and reuse over new abstractions. Only introduce new dependencies
when the existing stack cannot reasonably solve the problem.

## Verification Commands

Common commands:

```bash
flutter analyze
flutter test
flutter test test/path/to_test.dart
flutter build apk
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

Use targeted tests first when iterating. Full `flutter test` is useful when the
host dependency resolver is healthy, but this machine has previously stalled at
`Resolving dependencies...`.

## Manual Phone Testing

The human owner normally installs builds on a phone for final checks. For any
tracking or background-work change, give a concrete phone checklist instead of
claiming full validation from unit tests alone:

- Start a run and verify GPS lock, timer, distance, and pace.
- On Android, grant physical activity permission and verify cadence appears
  after a few steps.
- Lock the phone and wait several minutes.
- Confirm the notification remains and distance continues to update.
- Unlock and confirm there is no large GPS jump.
- Pause/resume and end the run.
- With auto-pause enabled, stop moving for at least 5 seconds and verify the app
  enters auto-paused even if GPS speed jitters; take several steps and verify it
  resumes.
- Repeat with physical activity permission denied. The app should hide cadence
  as unavailable and still auto-pause from low GPS motion when speed/displacement
  indicate the runner has stopped.
- Verify history details, route, splits, city/weather, and any AI/audience
  behavior touched by the change.
- For elevation work, compare a route with known climb against the saved result,
  and repeat once with network disabled to verify fallback behavior.
- Start a second run without force-killing the app.

## Known Documentation Drift

`CLAUDE.md` is useful but partly stale in dependency-version examples. Prefer
`pubspec.yaml` for exact package versions and `lib/app/router.dart` for current
routes. For example, the active audience tab route is `/audience`, not `/ai`.

## Follow-Up Backlog

- Elevation source tracking: add a persisted `elevationSource` or
  `elevationComputedAt` field so old records can distinguish "true 0 m climb"
  from "missing/default 0 m". Until then, new runs should use saved
  `elevationGainMeters`; old imported or pre-DEM records may need manual or
  migration-time recalculation.
- Regression tests: once Flutter dependency resolution works on this host, add
  tests for two-stage run finalization, `updateSessionEnrichment` not duplicating
  split rows, result/share providers refreshing after session enrichment, share
  card elevation source behavior, and user-renamed runs not being overwritten by
  background enrichment.
