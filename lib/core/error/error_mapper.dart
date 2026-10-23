import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// Converts anything thrown by the data layer into a [Failure].
///
/// Repositories should wrap their calls with [mapError] in a `catch` block
/// rather than rethrowing raw exceptions, so the presentation layer always
/// receives something it can render.
Failure mapError(Object error, [StackTrace? stackTrace]) {
  if (error is Failure) return error;

  if (error is PostgrestException) {
    // 42P01 = undefined_table, PGRST202 = function not found,
    // PGRST205 = table not in the schema cache.
    const setupCodes = <String>{'42P01', 'PGRST202', 'PGRST205'};
    if (setupCodes.contains(error.code)) {
      return SetupFailure(
        'The database is not set up yet. Run the migrations in '
        'supabase/migrations (see docs/setup.md).',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    // 42501 = insufficient_privilege, raised when an RLS policy denies a write.
    if (error.code == '42501') {
      return PermissionFailure(cause: error, stackTrace: stackTrace);
    }

    // PGRST116 = no rows returned for a single-row request.
    if (error.code == 'PGRST116') {
      return NotFoundFailure(cause: error, stackTrace: stackTrace);
    }

    return ServerFailure(cause: error, stackTrace: stackTrace);
  }

  if (error is AuthException) {
    return AuthFailure(
      error.message.isEmpty
          ? 'Sign in failed. Please try again.'
          : error.message,
      cause: error,
      stackTrace: stackTrace,
    );
  }

  if (error is TimeoutException) {
    return NetworkFailure(cause: error, stackTrace: stackTrace);
  }

  // SocketException lives in dart:io, which is unavailable on web. Match on
  // the type name instead so this file stays platform-agnostic.
  if (error.runtimeType.toString() == 'SocketException' ||
      error.runtimeType.toString() == 'ClientException') {
    return NetworkFailure(cause: error, stackTrace: stackTrace);
  }

  return UnknownFailure(cause: error, stackTrace: stackTrace);
}
