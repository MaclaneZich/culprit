# Changelog

All notable changes to Culprit are documented here. This project follows
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-07-20

First tagged release. The core loop works end to end, and the app is fully
usable with no API key.

### Logging

- Single timeline interleaving meals, context entries, and symptom episodes.
- Quick meal capture: opens the camera on entry, then a fast confirm step for
  the components a photo cannot show (butter, sauces, garlic, sweeteners).
  Manual entry is always available.
- Daily context check-in for sleep, stress, alcohol, caffeine, exercise,
  hydration, skipped meals, illness, and optional cycle phase.
- One-handed symptom logging sized for use during an attack: symptom-type
  chips, a severity slider, and time-since-last-meal derived from the log but
  editable.

### Analysis

- Denominator-aware association scoring: symptom rate after a candidate is
  compared against the base rate across all logged meals, so a
  frequently-eaten food is not blamed for preceding attacks by coincidence.
- Empirical-Bayes shrinkage penalizes small samples; candidates below the
  exposure floor are not ranked, and the ranking is withheld entirely below
  three logged episodes.
- Three lag windows (0–1 h, 1–4 h, 4–12 h), half-open, reported per candidate.
- Scoring at both food and trigger-class level, so a class signal (FODMAPs,
  lactose) surfaces even when no single member food is eaten often enough.
- Day-level factors thresholded from the context log and scored against the
  share of logged days that were symptomatic.

### Challenge Lab

- Generates a reintroduction schedule: baseline washout, then structured
  on/off cycles, with optional self-blinding guidance.
- Reads out reproduced, did not reproduce, or inconclusive. Only days that
  were both logged and adhered to carry evidence.

### Export

- One-tap PDF for a gastroenterologist: logging completeness, symptom
  frequency, ranked candidates with the underlying counts, day-level factors,
  and challenge results.
- CSV export of every logged table.

### Optional AI assist

- Vision ingredient pre-fill from a meal photo, stored as unconfirmed and
  down-weighted in analysis until the user confirms it.
- Plain-words narration of the already-computed ranking.
- The model never receives raw logs, only a single photo, or computed
  statistics. Keys are entered in-app and stored in the iOS keychain.

### Privacy and safety

- Local-first: all health data stays in an on-device SQLite database. No
  account, no cloud sync, no analytics SDKs.
- First-run disclaimer must be acknowledged before anything can be logged.
- Persistent reminder that celiac testing requires actively eating gluten.
- Insight copy constrained to "candidate", "associated with", "worth testing",
  enforced by a test that fails the build on causal or diagnostic language.
- Full data export and full data delete in Settings.

### Known limitations

- Not yet run on a physical iOS device. iOS compilation and the camera,
  keychain, notification, and share-sheet paths are unverified; the CI
  workflow builds for iOS to cover the compile half of that gap.
- README screenshots not captured.
