/// Shared user-facing copy.
///
/// Culprit surfaces associations, never causes. All analysis-adjacent copy
/// lives here so the framing stays honest in one place, and a test
/// (`test/honest_copy_test.dart`) fails the build if causal or diagnostic
/// language creeps into these strings or the insight UI.
abstract final class Copy {
  static const appName = 'Culprit';

  // Framing vocabulary. Insight surfaces must use these words.
  static const candidate = 'candidate';
  static const worthTesting = 'Worth testing';
  static const associatedWith = 'associated with';
  static const discussWithDoctor = 'Bring this list to your gastroenterologist.';

  static const insightsHeader = 'Candidates worth testing';
  static const insightsSubheader =
      'Associations from your log — not a diagnosis. A challenge or a '
      'clinician can turn a candidate into an answer.';

  static const celiacReminder =
      'Keep eating gluten until you have been tested for celiac disease. '
      'The blood test only works while gluten is in your diet, so talk to '
      'your doctor before eliminating anything.';

  static const disclaimerTitle = 'Before you start';
  static const disclaimerBody =
      'Culprit finds patterns in what you log and turns them into a short '
      'list of candidates to test. It is not a medical device, it does not '
      'make a determination about what is wrong, and it does not replace a '
      'GI workup. Share what it finds with a clinician.\n\n'
      'Your data stays on this phone. Nothing is uploaded unless you '
      'choose to connect your own AI key, and even then only computed '
      'summaries are sent — never your raw log.';
  static const disclaimerAck = 'I understand — candidates, not answers';

  static const onboardingLogEverything =
      'Log every meal, especially the boring ones. If Culprit only sees the '
      'meals before a bad night, it cannot tell a real trigger from a food '
      'you simply eat often. Calm days are half the evidence.';

  static const emptyTimeline =
      'Nothing logged yet. Start with your next meal — good days count as '
      'much as bad ones.';
  static const emptyInsights =
      'Not enough log yet to rank candidates. Keep logging every meal and '
      'the daily check-in; most people see a first ranking within two weeks.';

  static const challengeIntro =
      'A correlation gets you a list; a challenge gets you an answer. '
      'Culprit will schedule washout days and structured on/off days for '
      'one candidate so you can see whether symptoms actually follow it.';

  static const notMedicalAdvice =
      'Culprit is not medical advice and not a diagnosis.';
}
