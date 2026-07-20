/// Core vocabulary of the app. These enums are stored in the database by
/// [name], so renaming a value is a schema migration — add, don't rename.
library;

enum SymptomType {
  diarrhea('Diarrhea'),
  vomiting('Vomiting'),
  reflux('Reflux'),
  pain('Pain'),
  bloating('Bloating'),
  nausea('Nausea'),
  other('Other');

  const SymptomType(this.label);
  final String label;
}

/// Trigger classes. Analysis runs at this level as well as per-food, because
/// the real signal is often a class (FODMAPs) rather than a single food.
enum TriggerTag {
  fructan('Fructan', 'FODMAP: wheat, onion, garlic'),
  lactose('Lactose', 'FODMAP: milk, soft cheese, ice cream'),
  fructose('Fructose', 'FODMAP: honey, apples, HFCS'),
  polyol('Polyol', 'FODMAP: stone fruit, sugar alcohols'),
  gos('GOS', 'FODMAP: beans, lentils, cashews'),
  gluten('Gluten', 'Wheat, barley, rye'),
  dairy('Dairy', 'All milk-derived'),
  highFat('High fat', 'Fried, creamy, fatty cuts'),
  caffeine('Caffeine', 'Coffee, tea, energy drinks'),
  alcohol('Alcohol', 'Any alcoholic drink'),
  spicy('Spicy', 'Chili heat'),
  histamine('Histamine', 'Aged, fermented, cured'),
  artificialSweetener('Artificial sweetener', 'Aspartame, sucralose, etc.');

  const TriggerTag(this.label, this.hint);
  final String label;
  final String hint;
}

enum PortionSize {
  small('Small'),
  medium('Medium'),
  large('Large');

  const PortionSize(this.label);
  final String label;
}

enum MealSource {
  home('Home'),
  restaurant('Restaurant'),
  packaged('Packaged');

  const MealSource(this.label);
  final String label;
}

/// Continuous life context, logged on calm days too. The gut-brain axis is a
/// first-class citizen here, not a footnote.
enum ContextType {
  sleepHours('Sleep', 'hours'),
  stress('Stress', '1-5'),
  alcoholUnits('Alcohol', 'units'),
  caffeineMg('Caffeine', 'mg'),
  exerciseIntensity('Exercise', '0-3'),
  skippedMeal('Skipped meal', 'yes/no'),
  menstrualPhase('Cycle phase', 'phase'),
  illness('Illness', 'yes/no'),
  hydration('Hydration', '1-3');

  const ContextType(this.label, this.unit);
  final String label;
  final String unit;
}

enum MenstrualPhase {
  menstrual('Menstrual'),
  follicular('Follicular'),
  ovulation('Ovulation'),
  luteal('Luteal');

  const MenstrualPhase(this.label);
  final String label;
}

/// Whether an ingredient on a meal was confirmed by the user or only guessed
/// (e.g. by the optional vision model). Guessed rows are down-weighted in
/// analysis and visually marked until confirmed.
enum IngredientConfidence {
  confirmed('Confirmed'),
  guessed('Guessed');

  const IngredientConfidence(this.label);
  final String label;
}

enum ChallengeStatus {
  planned('Planned'),
  running('Running'),
  completed('Completed'),
  abandoned('Abandoned');

  const ChallengeStatus(this.label);
  final String label;
}

/// The kind of day in a reintroduction schedule.
enum ChallengeDayKind {
  washout('Washout', 'Avoid the candidate. Let your baseline settle.'),
  on('On day', 'Eat the candidate deliberately, normal portion.'),
  off('Off day', 'Avoid the candidate again.');

  const ChallengeDayKind(this.label, this.instruction);
  final String label;
  final String instruction;
}

enum ChallengeOutcome {
  reproduced('Reproduced'),
  notReproduced('Did not reproduce'),
  inconclusive('Inconclusive');

  const ChallengeOutcome(this.label);
  final String label;
}
