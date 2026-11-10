# Contributing to Culprit

Thanks for looking. Culprit is a small, opinionated tool built for one job:
turning a complete self-tracked log into an honest shortlist of candidates to
test with a clinician.

## Read this first

[ARCHITECTURE.md](ARCHITECTURE.md) explains the one rule that shapes the
codebase: **statistics are computed in Dart; the LLM only narrates numbers it
was handed.** A change that lets a model see or infer the raw log is not a
change we can take.

## Scope discipline

If a feature does not help identify triggers, it does not ship. Culprit is not
a calorie tracker, not a macro tracker, not a weight-loss app, and not a
general health platform. It does not judge food.

Things that are in scope: making logging faster, making the statistics more
honest, making the doctor export more useful, making the challenge module
easier to run correctly.

## Non-negotiables

These are the reasons the app works. A PR that breaks one won't be merged.

1. **The denominator is everything.** Anything that makes logging calm-day
   meals harder, or that computes a rate without comparing it to a base rate,
   is a regression.
2. **Context is continuous.** Non-food factors are logged on good days too,
   for the same reason.
3. **Symptoms stay structured.** Type, severity, and time-since-last-meal are
   what make an episode analyzable.
4. **Candidates, never causes.** Insight copy is constrained to "candidate,"
   "associated with," "worth testing." `test/honest_copy_test.dart` enforces
   this; if your change trips it, change the copy, not the test.
5. **Photo-assisted, not photo-only.** A photo is a capture and a timestamp.
   The confirm step is where the true components, including the invisible
   ones, get recorded.
6. **Local-first.** No analytics SDKs, no telemetry, no account. The only
   permitted network call is to the user's own opt-in LLM API.

## Health data must never enter the repo

- No actual logs, exports, screenshots of personal data, or database files. The
  `.gitignore` covers the obvious paths; check `git diff --staged` anyway.
- Seed and demo data must be obviously synthetic.
- No keys. The user's API key lives in the iOS keychain at runtime and is never
  read from the repo. `.env.example` documents this and holds nothing.

## Before you open a PR

```bash
flutter analyze     # must be clean
flutter test        # must be green
```

If you touched anything under `lib/analysis/`, add tests. That directory has no
Flutter dependency specifically so it can be tested hard and cheaply. Prefer
hand-computed expectations over snapshotting whatever the code currently does;
a test that just records current behavior won't catch the bug that matters.

If you touched the Drift schema, bump `schemaVersion` and add an `onUpgrade`
step. Additive changes only. Never lose a user's log.

## Style

- Match the surrounding code. Dart formatting via `dart format`.
- Colors, spacing, radii, and text styles come from `lib/core/theme/tokens.dart`.
  No magic numbers in widgets.
- Comments should explain a constraint the code can't show. Skip comments that
  restate the next line.
- Conventional commits (`feat:`, `fix:`, `docs:`, `refactor:`, `test:`).

## Reporting bugs

Include the Flutter version, the device or simulator, and what you expected.
**Do not paste your log data.** Describe the shape of the problem instead
(e.g. "a food eaten twice ranked above one eaten 30 times").

## A note on medical claims

Culprit does not diagnose and does not give medical advice. Please don't
propose features that would have it do either, however hedged the wording.
