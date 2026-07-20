import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../analysis/models.dart';
import '../../data/db/database.dart';
import '../../domain/enums.dart';

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

    pw.Widget section(String name, pw.Widget child) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 16),
            pw.Text(name, style: heading),
            pw.Container(
                margin: const pw.EdgeInsets.symmetric(vertical: 4),
                height: 0.5,
                color: line),
            child,
          ],
        );

    pw.Widget table(List<String> headers, List<List<String>> rows) =>
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: rows,
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
          child: pw.Text(
            'Culprit log summary — associations from self-tracking, not a '
            'diagnosis. Generated ${dateFormat.format(DateTime.now())} · '
            'page ${context.pageNumber}/${context.pagesCount}',
            style: caption,
          ),
        ),
        build: (context) => [
          pw.Text('GI Symptom & Food Log — Summary', style: title),
          pw.SizedBox(height: 4),
          pw.Text(
            completeness.firstLog != null && completeness.lastLog != null
                ? 'Self-tracked with Culprit, '
                    '${dateFormat.format(completeness.firstLog!)} – '
                    '${dateFormat.format(completeness.lastLog!)}'
                : 'Self-tracked with Culprit',
            style: const pw.TextStyle(fontSize: 10, color: secondary),
          ),
          section(
            'Logging completeness',
            pw.Text(
              '${completeness.totalMeals} meals over '
              '${completeness.loggedDays} days '
              '(${(completeness.mealCoverage * 100).round()}% of the span '
              'with 2+ meals logged); daily context recorded on '
              '${completeness.daysWithContext} days; '
              '${completeness.totalSymptoms} symptom episodes.',
              style: body,
            ),
          ),
          section(
            'Symptom frequency',
            sortedTypes.isEmpty
                ? pw.Text('No episodes logged.', style: body)
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
                      pw.Text(
                        '$severeCount episode(s) at severity 4–5.',
                        style: caption,
                      ),
                    ],
                  ),
          ),
          section(
            'Top candidates (associations, not causes)',
            !analysis.hasEnoughData
                ? pw.Text(
                    'Log not yet complete enough for a reliable ranking.',
                    style: body)
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
                      pw.Text(
                        'Score = symptom rate after the candidate (shrunk '
                        'toward the base rate for small samples) divided by '
                        'the rate after any meal. 1.0x means '
                        'indistinguishable from any meal. These are '
                        'candidates to test, not conclusions.',
                        style: caption,
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
                ? pw.Text('None run yet.', style: body)
                : table(
                    ['Candidate', 'Started', 'Status', 'Result'],
                    [
                      for (final c in challenges)
                        [
                          c.title,
                          dateFormat.format(c.startDate),
                          c.blinded ? '${c.status.label}, blinded' : c.status.label,
                          c.outcome?.label ?? '—',
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
            child: pw.Text(
              'Patient has been advised that these are statistical '
              'associations from passive self-tracking, and to continue '
              'eating gluten pending celiac evaluation.',
              style: const pw.TextStyle(fontSize: 9, color: secondary),
            ),
          ),
        ],
      ),
    );

    return report.save();
  }
}
