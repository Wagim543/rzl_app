/// Build-time configuration.
///
/// Values are injected with `--dart-define` (or `--dart-define-from-file=env.json`)
/// so that no key is ever committed to source control.
///
/// Run:
///   flutter run --dart-define-from-file=env.json
abstract final class Env {
  const Env._();

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// The Supabase publishable (anon) key.
  ///
  /// `anonKey:` is deprecated in `supabase_flutter` 2.17 in favour of
  /// `publishableKey:`, but the value is the same. The dart-define is named
  /// after the widely documented "anon key" so the team can find it in the
  /// dashboard without translation.
  static const String supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Base URL of the Supabase Edge Functions, used from Milestone 3 onward.
  static const String embeddingFnUrl = String.fromEnvironment(
    'EMBEDDING_FN_URL',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  /// Names of any required values that were not supplied at build time.
  static List<String> get missing {
    return <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
  }

  static const String setupHelp = '''
Missing build configuration.

Run the app with an environment file:

  flutter run --dart-define-from-file=env.json

Create env.json by copying env.example.json and filling in the Supabase
values. See docs/setup.md for the full instructions.''';
}
