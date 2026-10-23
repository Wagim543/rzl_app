import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/app_theme.dart';

/// Root widget. Holds nothing but wiring: theme, router, and theme mode.
///
/// Theme mode follows the operating system in Milestone 1. The user override
/// (FR-20, persisted on `profiles.dark_mode`) arrives in Milestone 2.
class RzlApp extends StatefulWidget {
  const RzlApp({this.router, super.key});

  /// Injectable for tests; defaults to the real router.
  final GoRouter? router;

  @override
  State<RzlApp> createState() => _RzlAppState();
}

class _RzlAppState extends State<RzlApp> {
  late final GoRouter _router = widget.router ?? createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RZL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      builder: (context, child) {
        // Clamp runaway text scaling so large accessibility settings cannot
        // break dense event cards.
        final scaler = MediaQuery.textScalerOf(context)
            .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.4);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: scaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
