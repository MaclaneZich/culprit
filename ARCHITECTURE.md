# Architecture

Short version: **statistics in Dart, LLM only narrates.** Everything else
follows from that and from keeping health data on the device.

## The load-bearing decision

The LLM never sees the raw log.

```
   Drift (SQLite, on device)
             │
             ▼
   AnalysisService                 reduces rows to exposure/symptom events,
             │                     thresholds context into day-level factors
             ▼
   StatsEngine  (pure Dart)        base rates, lag windows, shrinkage,
             │                     food- and tag-level rollups
             ├──────────────► InsightsScreen        ← the product, no key needed
             │
             └──► LlmService ──► "summarize these numbers"   ← optional polish
```

An LLM asked to find patterns in a raw food log will confidently invent them.
So it is never given the chance:

1. Dart computes exposure counts, co-occurrence inside configurable lag
   windows, base rates, and an association score with a small-sample penalty.
2. Only those computed numbers are serialized into the prompt
   (`LlmService._groundedSummary`). No meals, no dates, no notes, no photos.
3. The system prompt (`services/llm/prompts.dart`) forbids inventing patterns
   and requires "worth testing" framing.
4. With no API key, the ranked list renders from step 1 alone.

The one exception is the vision ingredient-guess, which sends a single photo
you just took, and its output is treated as *unconfirmed*: guessed
ingredients are stored with `IngredientConfidence.guessed`, shown with a `?`,
and down-weighted in the analysis until you confirm them.

If you are adding a feature, the question to ask is: *could this let the model
see or infer the raw log?* If yes, compute it in Dart first.

## Layout

```
lib/
  analysis/          pure Dart, no Flutter imports; runs under `dart test`
    models.dart              inputs/outputs of the engine
    stats_engine.dart        the denominator-aware scoring
    challenge_evaluator.dart reintroduction schedule + readout rules
    analysis_service.dart    bridges Drift rows -> engine events
  core/
    theme/           design tokens + ThemeData (no magic numbers in widgets)
    copy/            shared user-facing strings, guarded by a test
  data/db/           Drift tables, converters, seed ingredient library
  domain/            enums stored by name; add values, never rename
  features/          one folder per screen
  services/
    llm/             the only network surface in the app
    export/          PDF + CSV doctor report
    notifications/   local nudges
    photo_store.dart
  providers.dart     Riverpod wiring
```

`analysis/` deliberately has no Flutter dependency. It is the part most worth
testing and the part most expensive to get wrong.

## Data model notes

- **Enums are stored by `name`.** Renaming an enum value is a silent data
  migration. Add new values; never rename existing ones.
- **Migrations from day one.** `schemaVersion` starts at 1 with an
  `onUpgrade` hook already in place. Additive changes only. Never lose a
  user's log.
- **Ingredients are upserted by canonical name** and carry trigger-class tags,
  so the library grows with use and tags accumulate rather than overwrite.
- **One context value per type per day.** Re-logging a day's check-in replaces
  it rather than appending, so the day-level analysis has exactly one reading.

## Analysis details worth knowing

**Weighting.** A meal contributes weight 1.0. An unconfirmed (vision-guessed)
ingredient contributes 0.5 *for that ingredient only*, so a bad guess doesn't
discount the rest of the meal. A trigger tag counts at full weight if any
confirmed ingredient carries it.

Food and tag weights live in separate maps on `ExposureEvent`, because the two
key spaces overlap: a user may type an ingredient named "caffeine" or "gluten",
which are also `TriggerTag` names. One shared map would let an unconfirmed
ingredient silently discount the identically-named trigger class.

**Lag windows** are half-open, `[start, end)`. A symptom exactly at +1 h falls
in the 1–4 h window, not 0–1 h. Symptoms before the meal never count.

**Shrinkage** uses a pseudo-count of 3 observations behaving like the average
meal. Candidates below `minExposures` (3 weighted) are not ranked at all, and
the entire ranking is withheld below `minSymptoms` (3 episodes).

**Day factors** threshold continuous context into binary presence: sleep < 6 h
is `short-sleep`, stress ≥ 4 is `high-stress`, and so on
(`AnalysisService.buildDayFactors`). Their base rate is the share of *logged
days* that were symptomatic, so the same denominator logic applies.

**Challenge readout** only counts days that were both logged and adhered to.
Eating the candidate on an "off" day tells you nothing about the contrast, so
that day is excluded rather than counted against either arm.

## State management

Riverpod v3, plain providers (no codegen; `riverpod_generator` currently
conflicts with the Flutter-pinned `meta`). `databaseProvider` is overridden in
tests with an in-memory Drift database; `analysisProvider` recomputes from the
three stream providers whenever the log changes, which at personal-log scale is
effectively instant.

## Guardrails encoded in code

- `test/honest_copy_test.dart` fails the build on causal/diagnostic language in
  the insight-facing files. It strips comments and joins adjacent string
  literals first, so it checks what a user would actually read.
- `Copy` centralizes the framing vocabulary so it can be guarded in one place.
- The alert red in the design tokens is documented as reserved for
  high-severity (4–5) episodes only.
