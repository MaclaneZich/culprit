# Culprit

A local-first iOS app that helps one person find which foods and life factors
are **associated** with their GI symptoms.

Culprit makes it effortless to log every meal and daily context, log symptom
episodes with structure, and then surfaces a ranked list of candidate triggers
worth testing — plus a module to run a proper reintroduction challenge.

## What it is, honestly

The honest ceiling of passive self-tracking is **a ranked shortlist of things
worth testing**. Culprit is built to hit that ceiling well and then stop:

- It surfaces **candidates**, never causes. Every analysis surface says "worth
  testing," and a test in the suite fails the build if causal or diagnostic
  language creeps into the copy.
- It is **not a medical device**, not diagnostic, and does not replace a GI
  workup. A first-run disclaimer says so before anything can be logged.
- It reminds you, persistently, that **celiac testing requires actively eating
  gluten** — so don't eliminate foods before you've been worked up.

The output is designed to be handed to a gastroenterologist.

## Why most food diaries lie

**The denominator is everything.** People log when they feel bad. If the app
only sees the meals before an attack, it cannot tell a real trigger from a food
you simply eat often — the foods you eat most will always "lead" the most
attacks.

Culprit compares `rate(symptom | ate food)` against that food's **base rate**
across every logged meal. That only works if calm days are logged too, so the
whole app is built to make logging every meal the path of least resistance.

The same logic applies to non-food factors. Sleep, stress, alcohol, caffeine,
skipped meals, hard exercise, cycle phase, hydration, and illness are logged
continuously — not just on bad days — because for many people the gut-brain
axis is a live driver, not a footnote.

## Core loop

1. **Log every meal.** One tap to the camera; an optional vision guess
   pre-fills ingredients; you confirm or correct in seconds. The confirm step
   is what matters, because the real triggers are usually invisible in a photo
   — butter vs. oil, cream sauces, garlic and onion, wheat thickeners, HFCS,
   portion size.
2. **Check in daily.** A light morning/evening prompt for sleep, stress, and
   the day's factors.
3. **Log symptoms with structure.** Timestamp, type(s), severity 1–5, and time
   since the last meal — "20 minutes after eggs" and "3 hours after eggs"
   implicate different mechanisms, so the app captures which.
4. **Read the ranked candidates.** Association scores with a lag-window
   breakdown and the raw counts behind them.
5. **Run a challenge.** Correlation gets you a list; a structured
   reintroduction (washout, then scheduled on/off days) gets you an answer:
   reproduced / did not reproduce / inconclusive.
6. **Export for your doctor.** One-tap PDF and CSV.

## How the analysis works

Everything is computed on-device in Dart. For each candidate — a food, or a
trigger class like *fructan* or *lactose* — and each lag window (0–1 h, 1–4 h,
4–12 h), the engine counts weighted exposures and how many were followed by an
episode, then compares that rate to the base rate across all meals:

```
score = shrunk_rate / base_rate      where
shrunk_rate = (followed + m·base_rate) / (exposures + m),  m = 3
```

The shrinkage term is a small-sample penalty: it pulls sparse candidates toward
the base rate so one bad night after a rare food cannot top the ranking. A
score of `1.0×` means the candidate is indistinguishable from any random meal.

Analysis runs at both the food level and the **trigger-class** level, because
the real signal is often a class (FODMAPs) rather than a single food — four
different dairy foods eaten once each are invisible individually but visible as
`lactose`.

These are associations, not causal estimates, and the UI says so.

## The LLM is optional, and never sees your log

Culprit ships with **no API key** and is fully functional without one. If you
choose to connect your own key (Anthropic or OpenAI), it enables exactly two
things:

- a vision guess that pre-fills ingredients from a meal photo, which you then
  confirm;
- a plain-words narration of the **already-computed** ranking.

The model never sees raw logs. Dart computes the statistics; only those
computed numbers are sent, with a system prompt that forbids inventing patterns
and requires "worth testing" framing. If no key is set, the ranked list still
renders from the Dart stats alone. See [ARCHITECTURE.md](ARCHITECTURE.md).

Your key is stored in the iOS keychain via `flutter_secure_storage`. It is
never bundled, never committed, and never logged.

## Privacy

- **Local-first.** All health data lives in an on-device SQLite database.
- **No account, no cloud, no analytics SDKs.** The only network call the app
  can make is to the LLM API you opted into, over HTTPS, with your own key.
- **Full export and full delete** are in Settings.

## Setup

Requires the Flutter SDK (3.41+) and Xcode for device builds.

```bash
git clone https://github.com/culprit-app/culprit.git
cd culprit
flutter pub get
dart run build_runner build          # generates the Drift database code
flutter run                          # or open ios/Runner.xcworkspace in Xcode
```

Regenerating assets after editing the icon design:

```bash
dart run tool/generate_icon.dart     # SVG master -> assets/brand/app_icon_1024.png
dart run flutter_launcher_icons      # -> iOS app icon set
```

### Adding your own API key

There is nothing to configure at build time. Launch the app, go to
**Settings → AI assist**, pick a provider, and paste your key. It goes straight
to the keychain. To remove it, tap **Disconnect and delete key**.

`.env.example` exists only to document that no key is read from the repo.

## Screenshots

Not yet captured. To generate them, run the app on an iPhone simulator and
grab: the timeline with a few days logged, the Insights ranking with an
expanded candidate card, the Challenge Lab result readout, and the doctor
export preview. Drop the PNGs in `docs/screenshots/` and link them here.

## Tests

```bash
flutter analyze
flutter test
```

The suite concentrates where correctness matters most:

- `test/stats_engine_test.dart` — the denominator math, on synthetic data with
  hand-computed expectations. Includes the case the whole app exists for: a
  frequently-eaten innocent food that trails every symptom must **not** outrank
  a real trigger eaten a third as often.
- `test/insights_pipeline_test.dart` — the same scenario end to end, written
  through the real database, ranked by the real engine, rendered by the real
  Insights screen, and carried into the PDF.
- `test/challenge_evaluator_test.dart` — the reproduced / did-not-reproduce /
  inconclusive rules, including that non-adherent and unlogged days carry no
  evidence.
- `test/honest_copy_test.dart` — the copy guard described above.
- `test/widget_test.dart` — the onboarding disclaimer gate.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The architectural rule most worth
reading before you touch the analysis path is in
[ARCHITECTURE.md](ARCHITECTURE.md): **statistics in Dart, LLM only narrates.**

## Not medical advice

Culprit surfaces statistical associations from your own self-tracking to
discuss with a clinician. It is not a diagnosis, not a medical device, and not
a substitute for a GI workup. Do not eliminate foods or change treatment based
on what this app shows you without talking to your doctor — and keep eating
gluten until you have been tested for celiac disease.

## License

MIT — see [LICENSE](LICENSE).
