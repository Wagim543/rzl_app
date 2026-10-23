import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'core/supabase/supabase_client.dart';

/// Bootstrap only. No UI, no business logic.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.isConfigured) {
    runApp(const _SetupErrorApp());
    return;
  }

  await initSupabase();

  runApp(const ProviderScope(child: RzlApp()));
}

/// Shown when the app was built without `--dart-define-from-file=env.json`.
///
/// A readable screen beats a white one: the cause is almost always a missing
/// build flag, and the fix is one line in `docs/setup.md`.
class _SetupErrorApp extends StatelessWidget {
  const _SetupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(Icons.settings_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Configuration missing',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Missing: ${Env.missing.join(', ')}'),
                const SizedBox(height: 16),
                Text(Env.setupHelp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
