# Culprit

A local-first iOS app that ranks which foods and daily factors are associated with one person's GI symptoms, and then helps them test the top candidates with a structured reintroduction.

[![CI](https://github.com/MaclaneZich/culprit/actions/workflows/ci.yml/badge.svg)](https://github.com/MaclaneZich/culprit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-A85638.svg)](LICENSE)
![Status](https://img.shields.io/badge/status-prototype%2C%20not%20shipped-orange)

<img src="assets/brand/app_icon_1024.png" width="96" alt="Culprit app icon">

- **What it does.** You log every meal (one tap to the camera, optional vision guess, you confirm), a short daily check-in, and symptom episodes with timing. The app compares each candidate's symptom rate against its base rate across all logged meals and shows a ranked shortlist worth testing, then runs a washout and on/off challenge and exports a PDF for your doctor.
- **What I built.** Solo build, Flutter and Dart. A pure-Dart analysis engine with no Flutter imports, a Drift database with migrations from day one, an optional LLM layer that only narrates numbers already computed, and a test that fails the build if causal language reaches the user.
- **One number.** 32 tests across five files, including the case the app exists for: a frequently eaten innocent food that trails every symptom must not outrank a trigger eaten a third as often.

Prototype, not shipped. All health data stays on the device. No account, no cloud, no analytics SDKs. See [ARCHITECTURE.md](ARCHITECTURE.md) for the full design.

## How the analysis works

Everything is computed on the device in Dart. For each candidate (a food, or a trigger class such as lactose or fructan) and each lag window (0 to 1 h, 1 to 4 h, 4 to 12 h), the engine counts weighted exposures and how many were followed by an episode, then compares that rate to the base rate across all meals:

```
score = shrunk_rate / base_rate      where
shrunk_rate = (followed + m * base_rate) / (exposures + m),  m = 3
```

The shrinkage term pulls sparse candidates toward the base rate, so one bad night after a rare food cannot top the ranking. A score of `1.0x` means the candidate is indistinguishable from any random meal. Candidates with fewer than 3 weighted exposures are not ranked, and the whole ranking is withheld below 3 episodes.

The base-rate comparison is the reason the app pushes you to log calm days too. A food diary that only sees the meals before an attack will always blame whatever you eat most.

Analysis runs at the food level and at the trigger-class level, because four different dairy foods eaten once each are invisible individually but visible as `lactose`. Day-level factors (sleep, stress, alcohol, caffeine, skipped meals, exercise, cycle phase, hydration, illness) go through the same logic with logged days as the denominator.

These are associations, not causal estimates, and the UI says so.

## Engineering decisions

- **The build fails if causal language reaches the user.** `test/honest_copy_test.dart` strips comments and joins adjacent string literals in the six insight-facing files, then rejects `cause`, `diagnos`, `your trigger is` and `proves`, with explicit negations like "not a diagnosis" allowlisted. The tradeoff is that copy edits sometimes need a test change.
- **Statistics in Dart, the LLM only narrates.** The model is sent computed numbers, never meals, dates, notes or photos, with a system prompt that forbids inventing patterns. The tradeoff is that the narration cannot notice anything the engine did not compute.
- **No API key in the repo or the binary.** The optional Anthropic or OpenAI key is pasted into Settings at runtime and stored in the iOS keychain. The tradeoff is a setup step for the one optional feature.
- **The repository cannot accumulate health data.** `.gitignore` excludes the on-device databases, exports, meal photos, report PDFs and loose CSVs, with a carve-out for test fixtures.
- **Vision guesses are stored as unconfirmed.** A guessed ingredient is shown with a `?` and weighted 0.5 in the analysis until confirmed, for that ingredient only, so a bad guess does not discount the rest of the meal.
- **Half-open lag windows and strict challenge days.** A symptom exactly at +1 h falls in the 1 to 4 h window; a challenge day that was not logged or not adhered to is excluded rather than counted against either arm.

## Architecture

```
Drift (SQLite, on device)
        |
        v
AnalysisService        reduces rows to exposure and symptom events,
        |              thresholds context into day-level factors
        v
StatsEngine            pure Dart: base rates, lag windows, shrinkage,
        |              food- and tag-level rollups
        +------------> InsightsScreen        the product, no key needed
        |
        +--> LlmService --> "summarize these numbers"   optional
```

`lib/analysis/` has no Flutter dependency and runs under `dart test`. Layout, data model rules and state management are in [ARCHITECTURE.md](ARCHITECTURE.md).

## Tech stack

| Layer | Technology |
|---|---|
| Client | Flutter, Dart, iOS target |
| Database | Drift over SQLite, schema migrations from version 1 |
| State | Riverpod 3, plain providers |
| Analysis | Pure Dart package under `lib/analysis/` |
| Optional LLM | Anthropic or OpenAI over HTTPS with the user's own key, stored with `flutter_secure_storage` |
| Export | `pdf` and `printing` for the doctor report, CSV, `share_plus` |
| Charts and UI | fl_chart, flutter_svg, flutter_local_notifications |
| CI | GitHub Actions: analyze, test, Drift codegen drift check on Ubuntu; unsigned iOS build on macOS |

## Setup

Requires the Flutter SDK (3.41 or later) and Xcode for device builds.

```bash
git clone https://github.com/MaclaneZich/culprit.git
cd culprit
flutter pub get
dart run build_runner build          # generates the Drift database code
flutter run                          # or open ios/Runner.xcworkspace in Xcode
```

To enable the optional AI assist, launch the app, open Settings, pick a provider and paste your key. It goes straight to the keychain. "Disconnect and delete key" removes it. `.env.example` exists only to document that no key is read from the repo.

## Tests

```bash
flutter analyze
flutter test
```

| File | Covers |
|---|---|
| `test/stats_engine_test.dart` | The denominator math on synthetic data with hand-computed expectations |
| `test/insights_pipeline_test.dart` | The same scenario end to end: database, engine, Insights screen, PDF |
| `test/challenge_evaluator_test.dart` | Reproduced, did not reproduce and inconclusive rules |
| `test/honest_copy_test.dart` | The copy guard |
| `test/widget_test.dart` | The onboarding disclaimer gate |

CI runs these on every push and pull request, regenerates the Drift code and fails if the committed output differs, and compiles the iOS app unsigned on a macOS runner.

## What I would do next

- Ship it: screenshots, TestFlight, and an App Store listing.
- Add the trigger-class library as data rather than code so it can grow without a release.
- Put the challenge schedule on local notifications so on and off days are prompted, not remembered.

## Not medical advice

Culprit surfaces statistical associations from your own self-tracking to discuss with a clinician. It is not a diagnosis, not a medical device, and not a substitute for a GI workup. Do not eliminate foods or change treatment based on what this app shows you without talking to your doctor, and keep eating gluten until you have been tested for celiac disease.

## Contributing and license

See [CONTRIBUTING.md](CONTRIBUTING.md). The rule most worth reading first is in [ARCHITECTURE.md](ARCHITECTURE.md): statistics in Dart, LLM only narrates.

MIT. See [LICENSE](LICENSE).
