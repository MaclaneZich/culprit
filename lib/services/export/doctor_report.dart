import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../analysis/models.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';

/// Maps typographic punctuation to ASCII for the PDF.
///
/// The report uses the built-in Helvetica, which is WinAnsi-encoded: accented
/// Latin characters are fine, but the General Punctuation block is not, and
/// unsupported glyphs are dropped **silently** — a clinician would receive a
/// report with characters missing. Lag-window labels ("1–4 h") and several
/// report sentences use en/em dashes, so every string on its way into the
/// document goes through here. Bundling a Unicode TTF would also work; it
/// costs ~300KB of repo weight to gain characters this report never needs.
///
/// Public so `test/insights_pipeline_test.dart` can pin the mapping.
String asciiForPdf(String value) => value
    .replaceAll('—', '-') // em dash
    .replaceAll('–', '-') // en dash
    .replaceAll('·', '-') // middle dot
    .replaceAll('×', 'x') // multiplication sign
    .replaceAll('‘', "'")
    .replaceAll('’', "'")
    .replaceAll('“', '"')
    .replaceAll('”', '"')
    .replaceAll('…', '...');

/// One-tap PDF for the gastroenterologist. Clean summary, no fluff:
/// logging completeness, top candidates with the actual numbers, challenge
/// results, symptom frequency. Association framing throughout.
class DoctorReportBuilder {
  const DoctorReportBuilder();

  Future<Uint8List> build({
    required AnalysisResult analysis,
    required List<Symptom> symptoms,
    required List<Challenge> challenges,
  }) async {
    const ink = PdfColor.fromInt(0xFF1D1B17);
    const secondary = PdfColor.fromInt(0xFF6C675D);
    const accent = PdfColor.fromInt(0xFFA85638);
    const line = PdfColor.fromInt(0xFFE8E2D7);

    final title = pw.TextStyle(
        fontSize: 22, fontWeight: pw.FontWeight.bold, color: ink);
    final heading = pw.TextStyle(
        fontSize: 13, fontWeight: pw.FontWeight.bold, color: ink);
    const body = pw.TextStyle(fontSize: 9.5, color: ink);
    const caption = pw.TextStyle(fontSize: 8, color: secondary);
    final cellHeader = pw.TextStyle(
        fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: secondary);

    final report = pw.Document();
    final completeness = analysis.completeness;
    final dateFormat = DateFormat('MMM d, yyyy');

    pw.Widget text(String value, pw.TextStyle style) =>
        pw.Text(asciiForPdf(value), style: style);

    pw.Widget section(String name, pw.Widget child) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 16),
            text(name, heading),
            pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 4),
                height: 0.5,
                color: line),
            child,
          ],
        );

    pw.Widget table(List<String> headers, List<List<String>> rows) =>
        pw.TableHelper.fromTextArray(
          headers: [for (final h in headers) asciiForPdf(h)],
          data: [
            for (final row in rows) [for (final cell in row) asciiForPdf(cell)],
          ],
          headerStyle: cellHeader,
          cellStyle: body,
          border: null,
          headerDecoration:
              const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF3EFE7)),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        );

    // Symptom frequency rollup.
    final typeCounts = <SymptomType, int>{};
    var severeCount = 0;
    for (final symptom in symptoms) {
      if (symptom.severity >= 4) severeCount++;
      for (final type in symptom.types) {
        typeCounts[type] = (typeCounts[type] ?? 0) + 1;
      }
    }
    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    report.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 12),
          child: text(
            'Culprit log summary - associations from self-tracking, not a '
            'diagnosis. Generated ${dateFormat.format(DateTime.now())} - '
            'page ${context.pageNumber}/${context.pagesCount}',
            caption,
          ),
        ),
        build: (context) => [
          text('GI Symptom & Food Log - Summary', title),
          pw.SizedBox(height: 4),
          text(
            completeness.firstLog != null && completeness.lastLog != null
                ? 'Self-tracked with Culprit, '
                    '${dateFormat.format(completeness.firstLog!)} to '
                    '${dateFormat.format(completeness.lastLog!)}'
                : 'Self-tracked with Culprit',
            const pw.TextStyle(fontSize: 10, color: secondary),
          ),
          section(
            'Logging completeness',
            text(
              '${completeness.totalMeals} meals over '
              '${completeness.loggedDays} days '
              '(${(completeness.mealCoverage * 100).round()}% of the span '
              'with 2+ meals logged); daily context recorded on '
              '${completeness.daysWithContext} days; '
              '${completeness.totalSymptoms} symptom episodes.',
              body,
            ),
          ),
          section(
            'Symptom frequency',
            sortedTypes.isEmpty
                ? text('No episodes logged.', body)
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      table(
                        ['Symptom', 'Episodes'],
                        [
                          for (final entry in sortedTypes)
                            [entry.key.label, '${entry.value}'],
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      text(
                        '$severeCount episode(s) at severity 4-5.',
                        caption,
                      ),
                    ],
                  ),
          ),
          section(
            'Top candidates (associations, not causes)',
            !analysis.hasEnoughData
                ? text(
                    'Log not yet complete enough for a reliable ranking.',
                    body,
                  )
                : pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      table(
                        [
                          'Candidate',
                          'Level',
                          'Eaten',
                          'Best window',
                          'Followed',
                          'Rate vs base',
                          'Score',
                        ],
                        [
                          for (final c in analysis.candidates.take(8))
                            [
                              c.displayName,
                              c.kind == CandidateKind.tag ? 'class' : 'food',
                              c.totalExposures.toStringAsFixed(0),
                              c.bestWindow.window.label,
                              c.bestWindow.followed.toStringAsFixed(0),
                              '${(c.bestWindow.observedRate * 100).round()}% '
                                  'vs ${(c.bestWindow.baseRate * 100).round()}%',
                              '${c.score.toStringAsFixed(1)}x',
                            ],
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      text(
                        'Score = symptom rate after the candidate (shrunk '
                        'toward the base rate for small samples) divided by '
                        'the rate after any meal. 1.0x means '
                        'indistinguishable from any meal. These are '
                        'candidates to test, not conclusions.',
                        caption,
                      ),
                    ],
                  ),
          ),
          if (analysis.dayFactors.isNotEmpty)
            section(
              'Non-food factors (day-level)',
              table(
                ['Factor', 'Days present', 'Symptomatic', 'Rate vs base'],
                [
                  for (final f in analysis.dayFactors.take(6))
                    [
                      f.displayName,
                      '${f.factorDays}',
                      '${f.symptomaticFactorDays}',
                      '${(f.observedRate * 100).round()}% vs '
                          '${(f.baseRate * 100).round()}%',
                    ],
                ],
              ),
            ),
          section(
            'Reintroduction challenges',
            challenges.isEmpty
                ? text('None run yet.', body)
                : table(
                    ['Candidate', 'Started', 'Status', 'Result'],
                    [
                      for (final c in challenges)
                        [
                          c.title,
                          dateFormat.format(c.startDate),
                          c.blinded
                              ? '${c.status.label}, blinded'
                              : c.status.label,
                          c.outcome?.label ?? '-',
                        ],
                    ],
                  ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: accent, width: 0.5),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: text(
              'Patient has been advised that these are statistical '
              'associations from passive self-tracking, and to continue '
              'eating gluten pending celiac evaluation.',
              const pw.TextStyle(fontSize: 9, color: secondary),
            ),
          ),
        ],
      ),
    );

    return report.save();
  }
}
