import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/copy/copy.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../data/db/database.dart';
import '../../providers.dart';
import '../../services/export/csv_export.dart';
import '../../services/export/doctor_report.dart';
import '../../services/llm/llm_service.dart';
import '../../services/notifications/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// Public repository URL. Set this once the repo is published — the About
  /// card omits the line while it is empty rather than printing a link that
  /// does not resolve.
  static const repoUrl = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tones = context.tones;
    final settings = ref.watch(settingsProvider).value;
    final llmReady = ref.watch(llmServiceProvider).value != null;
    if (settings == null) {
      return const Scaffold(body: SizedBox.expand());
    }

    Future<void> updateSettings(AppSettingsCompanion patch) =>
        ref.read(databaseProvider).updateSettings(patch);

    Future<void> applyNotificationPrefs(AppSetting updated) =>
        NotificationService.instance.applyPreferences(
          morningReminder: updated.morningReminder,
          eveningReminder: updated.eveningReminder,
          mealReminders: updated.mealReminders,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.x4, 0, Space.x4, Space.x8),
        children: [
          _SectionLabel('Doctor export'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.picture_as_pdf_outlined,
                      color: tones.accent),
                  title: Text('Doctor report (PDF)', style: TypeRamp.body),
                  subtitle: Text(
                    'Completeness, top candidates, challenge results — '
                    'made to hand to a GI.',
                    style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
                  ),
                  onTap: () => _exportPdf(context, ref),
                ),
                Divider(height: 1, color: tones.line),
                ListTile(
                  leading:
                      Icon(Icons.table_chart_outlined, color: tones.accent),
                  title: Text('Raw data (CSV)', style: TypeRamp.body),
                  subtitle: Text(
                    'Every meal, symptom, and check-in you logged.',
                    style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
                  ),
                  onTap: () => _exportCsv(context, ref),
                ),
              ],
            ),
          ),
          _SectionLabel('AI assist (optional)'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    llmReady ? Icons.key : Icons.key_off_outlined,
                    color: llmReady ? tones.accent : tones.inkFaint,
                  ),
                  title: Text(
                    llmReady
                        ? 'Connected · ${LlmProvider.values.asNameMap()[settings.llmProvider]?.label ?? ''}'
                        : 'Connect your own API key',
                    style: TypeRamp.body,
                  ),
                  subtitle: Text(
                    'Photo ingredient guesses and a plain-words summary of '
                    'the computed numbers. Only computed statistics ever '
                    'leave the phone — never your raw log. The app is fully '
                    'usable without this.',
                    style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
                  ),
                  onTap: () => _configureKey(context, ref, settings),
                ),
              ],
            ),
          ),
          _SectionLabel('Reminders'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Morning check-in', style: TypeRamp.body),
                  value: settings.morningReminder,
                  onChanged: (v) async {
                    await updateSettings(
                        AppSettingsCompanion(morningReminder: Value(v)));
                    await applyNotificationPrefs(
                        settings.copyWith(morningReminder: v));
                  },
                ),
                SwitchListTile(
                  title: Text('Evening check-in', style: TypeRamp.body),
                  value: settings.eveningReminder,
                  onChanged: (v) async {
                    await updateSettings(
                        AppSettingsCompanion(eveningReminder: Value(v)));
                    await applyNotificationPrefs(
                        settings.copyWith(eveningReminder: v));
                  },
                ),
                SwitchListTile(
                  title: Text('Meal capture nudges', style: TypeRamp.body),
                  value: settings.mealReminders,
                  onChanged: (v) async {
                    await updateSettings(
                        AppSettingsCompanion(mealReminders: Value(v)));
                    await applyNotificationPrefs(
                        settings.copyWith(mealReminders: v));
                  },
                ),
              ],
            ),
          ),
          _SectionLabel('Tracking'),
          Card(
            child: SwitchListTile(
              title: Text('Track menstrual cycle', style: TypeRamp.body),
              subtitle: Text(
                'Adds cycle phase to the daily check-in and analysis.',
                style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
              ),
              value: settings.trackMenstrualCycle,
              onChanged: (v) => updateSettings(
                  AppSettingsCompanion(trackMenstrualCycle: Value(v))),
            ),
          ),
          _SectionLabel('Data'),
          Card(
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: tones.alert),
              title: Text('Delete all logged data',
                  style: TypeRamp.body.copyWith(color: tones.alert)),
              onTap: () => _deleteAll(context, ref),
            ),
          ),
          _SectionLabel('About'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Space.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Copy.notMedicalAdvice,
                      style: TypeRamp.bodySmall.copyWith(color: tones.ink)),
                  const SizedBox(height: Space.x2),
                  Text(
                    Copy.disclaimerBody,
                    style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
                  ),
                  const SizedBox(height: Space.x3),
                  Text(
                    repoUrl.isEmpty
                        ? 'Culprit is open source (MIT).'
                        : 'Culprit is open source (MIT): $repoUrl',
                    style: TypeRamp.caption.copyWith(color: tones.slate),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final analysis = ref.read(analysisProvider).value;
    if (analysis == null) return;
    final bytes = await const DoctorReportBuilder().build(
      analysis: analysis,
      symptoms: await db.allSymptoms(),
      challenges: await db.allChallenges(),
    );
    await Printing.sharePdf(bytes: bytes, filename: 'culprit_report.pdf');
  }

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final paths = await CsvExporter(ref.read(databaseProvider)).writeAll();
    await SharePlus.instance.share(
      ShareParams(files: [for (final path in paths) XFile(path)]),
    );
  }

  Future<void> _configureKey(
      BuildContext context, WidgetRef ref, AppSetting settings) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ApiKeySheet(settings: settings),
    );
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
            'All meals, symptoms, check-ins, and challenges will be '
            'permanently removed from this phone. There is no cloud copy. '
            'Consider exporting first.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete all')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).deleteAllLogData();
      await ref.read(photoStoreProvider).deleteAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All logged data deleted.')),
        );
      }
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    return Padding(
      padding: const EdgeInsets.only(top: Space.x5, bottom: Space.x2),
      child: Text(
        text.toUpperCase(),
        style: TypeRamp.caption.copyWith(
          color: tones.inkFaint,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _ApiKeySheet extends ConsumerStatefulWidget {
  const _ApiKeySheet({required this.settings});

  final AppSetting settings;

  @override
  ConsumerState<_ApiKeySheet> createState() => _ApiKeySheetState();
}

class _ApiKeySheetState extends ConsumerState<_ApiKeySheet> {
  late LlmProvider _provider = LlmProvider.values
          .asNameMap()[widget.settings.llmProvider] ??
      LlmProvider.anthropic;
  final _keyController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _keyController.text.trim();
    if (key.isEmpty || _saving) return;
    setState(() => _saving = true);
    await ref.read(llmKeyStoreProvider).write(key);
    await ref.read(databaseProvider).updateSettings(
        AppSettingsCompanion(llmProvider: Value(_provider.name)));
    ref.invalidate(llmServiceProvider);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _disconnect() async {
    await ref.read(llmKeyStoreProvider).delete();
    await ref
        .read(databaseProvider)
        .updateSettings(const AppSettingsCompanion(llmProvider: Value(null)));
    ref.invalidate(llmServiceProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tones = context.tones;
    final connected = widget.settings.llmProvider != null;

    return Padding(
      padding: EdgeInsets.only(
        left: Space.x4,
        right: Space.x4,
        top: Space.x5,
        bottom: MediaQuery.of(context).viewInsets.bottom + Space.x4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI assist', style: TypeRamp.headline.copyWith(color: tones.ink)),
          const SizedBox(height: Space.x1),
          Text(
            'Your key is stored in the iOS keychain and used only for the '
            'calls you trigger. It is never bundled, logged, or sent '
            'anywhere else.',
            style: TypeRamp.caption.copyWith(color: tones.inkSecondary),
          ),
          const SizedBox(height: Space.x4),
          SegmentedButton<LlmProvider>(
            segments: [
              for (final provider in LlmProvider.values)
                ButtonSegment(value: provider, label: Text(provider.label)),
            ],
            selected: {_provider},
            onSelectionChanged: (set) => setState(() => _provider = set.first),
          ),
          const SizedBox(height: Space.x4),
          TextField(
            controller: _keyController,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              hintText: _provider == LlmProvider.anthropic
                  ? 'sk-ant-…'
                  : 'sk-…',
            ),
          ),
          const SizedBox(height: Space.x5),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save key'),
          ),
          if (connected)
            Padding(
              padding: const EdgeInsets.only(top: Space.x2),
              child: TextButton(
                onPressed: _disconnect,
                child: Text('Disconnect and delete key',
                    style: TextStyle(color: tones.alert)),
              ),
            ),
        ],
      ),
    );
  }
}
