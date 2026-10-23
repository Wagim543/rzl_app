import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Initialises the Supabase client exactly once, before `runApp`.
///
/// Call this from `main()` only. Widgets and repository implementations must
/// obtain the client through `supabaseClientProvider` instead of reading
/// `Supabase.instance` directly.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseKey,
  );
}
