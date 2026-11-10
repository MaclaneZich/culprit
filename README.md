# Culprit

[![CI](https://github.com/MaclaneZich/culprit/actions/workflows/ci.yml/badge.svg)](https://github.com/MaclaneZich/culprit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-A85638.svg)](LICENSE)

A local-first iOS app that ranks which foods and daily factors are associated with one person's GI symptoms, so they have a short list worth testing with a clinician. It surfaces candidates, never causes, and the build fails if the UI copy says otherwise.

**Status:** prototype, not on the App Store. Built over summer 2026 with heavy use of Claude Code. Runs on the iOS simulator and on device; CI compiles the iOS target and runs the test suite on every push.

## What it does

1. Log every meal. Camera first, optional vision guess, you confirm the ingredients.
2. Daily check-in for sleep, stress, alcohol, caffeine, exercise, cycle phase, hydration, illness.
3. Log symptom episodes with timestamp, type, severity 1 to 5, and time since the last meal.
4. Read a ranked list of candidate triggers with the counts behind each score.
5. Run a structured reintroduction challenge: washout, scheduled on/off days, a reproduced / did not reproduce / inconclusive verdict.
6. Export a PDF and CSV for your doctor.

## How the ranking works

Everything is computed on-device in Dart. Most food diaries only see the meals before an attack, so the foods you eat most always "lead" the most attacks. Culprit compares `rate(symptom | ate food)` against that food's base rate across every logged meal, which is why the app pushes you to log calm days too.

For each candidate (a food, or a class like *fructan* or *lactose*) and each lag window (0 to 1 h, 1 to 4 h, 4 to 12 h):

```
score = shrunk_rate / base_rate
shrunk_rate = (followed + m * base_rate) / (exposures + m),  m = 3
```

The shrinkage term pulls sparse candidates toward the base rate so one bad night after a rare food can't top the list. A score of 1.0 means the candidate looks like any random meal. These are associations, not causal estimates, and the UI says so.

## Tech

- Flutter / Dart, iOS target
- Drift (SQLite) for on-device storage; no account, no cloud, no analytics
- Optional LLM layer (Anthropic or OpenAI, your own key, stored in the iOS keychain via `flutter_secure_storage`). It only pre-fills ingredients from a photo and narrates the already-computed ranking. Raw logs never leave the device.
- PDF and CSV export
- GitHub Actions: analyze, test, Drift codegen drift check, unsigned iOS build on macOS

## Three things enforced by tests, not discipline

- `test/honest_copy_test.dart` rejects causal verbs, "diagnos*", verdict phrasing and proof claims in any user-facing string. Negations like "not a diagnosis" are allowed.
- `.gitignore` excludes on-device databases, exports, meal photos, report PDFs and loose CSVs, so a device's data can't be committed by accident.
- No API key exists in the repo or the binary. `.env.example` documents that there is nothing to configure.

## Run it

Flutter SDK 3.41+ and Xcode.

```bash
git clone https://github.com/MaclaneZich/culprit.git
cd culprit
flutter pub get
dart run build_runner build   # Drift codegen
flutter run                   # or open ios/Runner.xcworkspace
```

To use the optional AI assist, open Settings in the app and paste a provider key. To remove it, tap Disconnect and delete key.

## Tests

```bash
flutter analyze
flutter test
```

`stats_engine_test` covers the denominator math on synthetic data, including the case the app exists for: a common innocent food that trails every symptom must not outrank a true trigger eaten a third as often. `insights_pipeline_test` runs that scenario end to end through the database, engine, Insights screen and PDF. `challenge_evaluator_test` covers the reintroduction rules. See [ARCHITECTURE.md](ARCHITECTURE.md) for the one rule that matters: statistics in Dart, the LLM only narrates.

## Limitations

- Prototype. No App Store release, no TestFlight, no users yet.
- Screenshots are not in the repo yet.
- Association scores from one person's self-tracking are noisy. The challenge module exists because correlation alone is not an answer.
- Not a medical device and not a diagnosis. Keep eating gluten until you have been tested for celiac disease.

## License

MIT. See [LICENSE](LICENSE).
