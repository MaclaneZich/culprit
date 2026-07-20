import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/copy/copy.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/database.dart';
import '../../providers.dart';
import '../../services/notifications/notification_service.dart';

/// Three screens, then a required disclaimer acknowledgment. The honest
/// limits are stated before the first meal is ever logged.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _acknowledged = false;
  bool _finishing = false;

  static const _pages = [
    (
      art: 'assets/illustrations/onboarding_log.svg',
      title: 'Find your culprit',
      body:
          'Log meals, daily context, and symptom episodes in one place. '
          'Culprit compares how often symptoms follow each food against how '
          'often they follow any meal, and ranks what stands out.',
    ),
    (
      art: 'assets/illustrations/onboarding_everything.svg',
      title: 'Log everything, not just bad days',
      body: Copy.onboardingLogEverything,
    ),
    (
      art: 'assets/illustrations/onboarding_limits.svg',
      title: 'Candidates, not answers',
      body:
          'Passive tracking can only surface candidates worth testing. A '
          'structured reintroduction challenge — and your doctor — turn a '
          'candidate into an answer. ${Copy.celiacReminder}',
    ),
  ];

  Future<void> _finish() async {
    if (!_acknowledged || _finishing) return;
    setState(() => _finishing = true);
    await ref.read(databaseProvider).updateSettings(
          const AppSettingsCompanion(
            disclaimerAccepted: Value(true),
            onboardingComplete: Value(true),
          ),
        );
    await NotificationService.instance.applyPreferences(
      morningReminder: true,
      eveningReminder: true,
      mealReminders: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final lastPage = _page == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.all(Space.x8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - Space.x8 * 2,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(page.art, width: 200),
                            const SizedBox(height: Space.x8),
                            Text(page.title,
                                style: TypeRamp.display
                                    .copyWith(color: tones.ink, fontSize: 32)),
                            const SizedBox(height: Space.x4),
                            Text(page.body,
                                style: TypeRamp.body
                                    .copyWith(color: tones.inkSecondary)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.x6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        Container(
                          margin:
                              const EdgeInsets.symmetric(horizontal: Space.x1),
                          width: i == _page ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                i == _page ? tones.accent : tones.cardSunken,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Space.x5),
                  if (lastPage) ...[
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        Copy.disclaimerAck,
                        style: TypeRamp.bodySmall.copyWith(color: tones.ink),
                      ),
                      value: _acknowledged,
                      onChanged: (v) =>
                          setState(() => _acknowledged = v ?? false),
                    ),
                    const SizedBox(height: Space.x2),
                    FilledButton(
                      onPressed: _acknowledged && !_finishing ? _finish : null,
                      child: const Text('Start logging'),
                    ),
                  ] else
                    FilledButton(
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                      ),
                      child: const Text('Continue'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
