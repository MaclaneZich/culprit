import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/copy/copy.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/app_shell.dart';
import 'providers.dart';

class CulpritApp extends ConsumerWidget {
  const CulpritApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: Copy.appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: settings.when(
        loading: () => const _Splash(),
        error: (error, _) => _StartupError(error: error),
        data: (s) => s.disclaimerAccepted && s.onboardingComplete
            ? const AppShell()
            : const OnboardingScreen(),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: SizedBox.expand());
}

class _StartupError extends StatelessWidget {
  const _StartupError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Culprit could not open its database.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
