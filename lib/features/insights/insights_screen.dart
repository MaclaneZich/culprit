import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../analysis/models.dart';
import '../../core/copy/copy.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../providers.dart';
import '../challenge/new_challenge_sheet.dart';

/// The ranked candidate list. Every surface here is constrained to
/// association language — candidates worth testing, never causes. Fully
/// functional with zero LLM; narration is optional polish.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tones = context.tones;
    final analysis = ref.watch(analysisProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: analysis.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (result) => ListView(
          padding: const EdgeInsets.fromLTRB(Space.x4, 0, Space.x4, Space.x8),
          children: [
            Text(
              Copy.insightsSubheader,
              style: TypeRamp.bodySmall.copyWith(color: tones.inkSecondary),
            ),
            const SizedBox(height: Space.x4),
            _CompletenessCard(report: result.completeness),
            const SizedBox(height: Space.x4),
            const _CeliacReminder(),
            const SizedBox(height: Space.x5),
            if (!result.hasEnoughData)
              const _NotEnoughData()
            else ...[
              Text(Copy.insightsHeader,
                  style: TypeRamp.headline.copyWith(color: tones.ink)),
              const SizedBox(height: Space.x3),
              const _NarrationCard(),
              for (final candidate in result.candidates.take(8))
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.x3),
                  child: _CandidateCard(candidate: candidate),
                ),
              if (result.dayFactors.isNotEmpty) ...[
                const SizedBox(height: Space.x5),
                Text('Life factors',
                    style: TypeRamp.headline.copyWith(color: tones.ink)),
                const SizedBox(height: Space.x1),
                Text(
                  'Day-level associations: how often a symptomatic day '
                  'followed each factor, against your overall rate.',
                  style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
                ),
                const SizedBox(height: Space.x3),
                for (final factor in result.dayFactors.take(6))
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.x3),
                    child: _DayFactorCard(factor: factor),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CompletenessCard extends StatelessWidget {
  const _CompletenessCard({required this.report});

  final CompletenessReport report;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log completeness',
                style: TypeRamp.label.copyWith(color: tones.inkSecondary)),
            const SizedBox(height: Space.x3),
            Row(
              children: [
                _Stat(number: '${report.totalMeals}', label: 'meals'),
                _Stat(number: '${report.totalSymptoms}', label: 'episodes'),
                _Stat(number: '${report.loggedDays}', label: 'days logged'),
              ],
            ),
            const SizedBox(height: Space.x4),
            _CoverageBar(
              label: 'Days with 2+ meals',
              fraction: report.mealCoverage,
            ),
            const SizedBox(height: Space.x2),
            _CoverageBar(
              label: 'Days with a check-in',
              fraction: report.contextCoverage,
            ),
            const SizedBox(height: Space.x3),
            Text(
              'The ranking is only as honest as the log — meals on calm days '
              'are what separate real candidates from coincidence.',
              style: TypeRamp.caption.copyWith(color: tones.inkFaint),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: TypeRamp.statNumber.copyWith(color: tones.ink)),
          Text(label, style: TypeRamp.caption.copyWith(color: tones.inkSecondary)),
        ],
      ),
    );
  }
}

class _CoverageBar extends StatelessWidget {
  const _CoverageBar({required this.label, required this.fraction});

  final String label;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Row(
      children: [
        SizedBox(
          width: 148,
          child: Text(label,
              style: TypeRamp.caption.copyWith(color: tones.inkSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: fraction.clamp(0, 1),
              minHeight: 6,
              backgroundColor: tones.cardSunken,
              color: tones.accent,
            ),
          ),
        ),
        const SizedBox(width: Space.x2),
        Text('${(fraction * 100).round()}%',
            style: TypeRamp.caption.copyWith(color: tones.ink)),
      ],
    );
  }
}

class _CeliacReminder extends StatelessWidget {
  const _CeliacReminder();

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Container(
      padding: const EdgeInsets.all(Space.x3),
      decoration: BoxDecoration(
        color: tones.cardSunken,
        borderRadius: Corner.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: tones.slate),
          const SizedBox(width: Space.x2),
          Expanded(
            child: Text(
              Copy.celiacReminder,
              style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotEnoughData extends StatelessWidget {
  const _NotEnoughData();

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.x8),
      child: Column(
        children: [
          SvgPicture.asset('assets/illustrations/no_insights.svg', width: 160),
          const SizedBox(height: Space.x5),
          Text(
            Copy.emptyInsights,
            textAlign: TextAlign.center,
            style: TypeRamp.body.copyWith(color: tones.inkSecondary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CandidateCard extends StatefulWidget {
  const _CandidateCard({required this.candidate});

  final CandidateScore candidate;

  @override
  State<_CandidateCard> createState() => _CandidateCardState();
}

class _CandidateCardState extends State<_CandidateCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final candidate = widget.candidate;
    final best = candidate.bestWindow;

    return Card(
      child: InkWell(
        borderRadius: Corner.lgAll,
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(Space.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(candidate.displayName,
                            style: TypeRamp.title.copyWith(color: tones.ink)),
                        const SizedBox(height: 2),
                        Text(
                          candidate.kind == CandidateKind.tag
                              ? 'trigger class · ${_strengthLabel(candidate.strength)}'
                              : 'food · ${_strengthLabel(candidate.strength)}',
                          style:
                              TypeRamp.caption.copyWith(color: tones.inkFaint),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${candidate.score.toStringAsFixed(1)}×',
                        style:
                            TypeRamp.statNumber.copyWith(color: tones.accent),
                      ),
                      Text('vs any meal',
                          style: TypeRamp.caption
                              .copyWith(color: tones.inkFaint)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Space.x3),
              Text(
                'Seen ${best.exposures.toStringAsFixed(0)} times · symptoms '
                'followed ${best.followed.toStringAsFixed(0)} times within '
                '${best.window.label} '
                '(${(best.observedRate * 100).round()}% vs base '
                '${(best.baseRate * 100).round()}%)',
                style: TypeRamp.bodySmall.copyWith(color: tones.inkSecondary),
              ),
              if (_expanded) ...[
                const SizedBox(height: Space.x4),
                _WindowChart(candidate: candidate),
              ],
              const SizedBox(height: Space.x4),
              Row(
                children: [
                  Text(
                    Copy.worthTesting,
                    style: TypeRamp.label.copyWith(color: tones.accent),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        showNewChallengeSheet(context, candidate: candidate),
                    child: const Text('Start a challenge'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _strengthLabel(EvidenceStrength strength) => switch (strength) {
        EvidenceStrength.limited => 'limited evidence',
        EvidenceStrength.moderate => 'moderate evidence',
        EvidenceStrength.strong => 'strong evidence',
      };
}

/// Per-lag-window association scores, with the base-rate line at 1.0.
class _WindowChart extends StatelessWidget {
  const _WindowChart({required this.candidate});

  final CandidateScore candidate;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final windows = candidate.windows;
    final maxLift = windows
        .map((w) => w.lift)
        .fold<double>(1.0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxLift * 1.25).clamp(1.5, double.infinity),
          barTouchData: const BarTouchData(enabled: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: 1,
              color: tones.inkFaint,
              strokeWidth: 1,
              dashArray: const [4, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: TypeRamp.caption.copyWith(color: tones.inkFaint),
                labelResolver: (_) => 'any meal',
              ),
            ),
          ]),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= windows.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      windows[i].window.label,
                      style:
                          TypeRamp.caption.copyWith(color: tones.inkSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < windows.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: windows[i].lift,
                  width: 28,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                  color: windows[i].window.label ==
                          candidate.bestWindow.window.label
                      ? tones.accent
                      : tones.cardSunken,
                ),
              ]),
          ],
        ),
      ),
    );
  }
}

class _DayFactorCard extends StatelessWidget {
  const _DayFactorCard({required this.factor});

  final DayFactorScore factor;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.x4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(factor.displayName,
                      style: TypeRamp.title.copyWith(color: tones.ink)),
                  const SizedBox(height: 2),
                  Text(
                    'Symptomatic on ${factor.symptomaticFactorDays} of '
                    '${factor.factorDays} days '
                    '(${(factor.observedRate * 100).round()}% vs base '
                    '${(factor.baseRate * 100).round()}%)',
                    style:
                        TypeRamp.caption.copyWith(color: tones.inkSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${factor.lift.toStringAsFixed(1)}×',
              style: TypeRamp.statNumber.copyWith(color: tones.slate),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// Optional narration of the grounded numbers. Renders nothing when no API
/// key is configured — the ranked list above is the product.
class _NarrationCard extends ConsumerStatefulWidget {
  const _NarrationCard();

  @override
  ConsumerState<_NarrationCard> createState() => _NarrationCardState();
}

class _NarrationCardState extends ConsumerState<_NarrationCard> {
  String? _narration;
  bool _loading = false;
  String? _error;

  Future<void> _narrate() async {
    final llm = ref.read(llmServiceProvider).value;
    final analysis = ref.read(analysisProvider).value;
    if (llm == null || analysis == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final text = await llm.narrateInsights(analysis);
      if (mounted) setState(() => _narration = text);
    } on Exception catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final llmReady = ref.watch(llmServiceProvider).value != null;
    if (!llmReady) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.x3),
      child: Card(
        color: tones.cardSunken,
        child: Padding(
          padding: const EdgeInsets.all(Space.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_narration != null) ...[
                Text(_narration!,
                    style: TypeRamp.bodySmall.copyWith(color: tones.ink)),
                const SizedBox(height: Space.x2),
                Text(
                  'AI summary of the numbers below — nothing beyond them.',
                  style: TypeRamp.caption.copyWith(color: tones.inkFaint),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _error ?? 'Summarize the ranked numbers in plain words.',
                        style: TypeRamp.caption.copyWith(
                          color: _error != null
                              ? tones.alert
                              : tones.inkSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _loading ? null : _narrate,
                      child: Text(_loading ? 'Working…' : 'Summarize'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
