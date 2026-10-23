import 'failure.dart';

/// Copies a [Failure]'s message, falling back for anything unclassified.
///
/// Screens must never cast blindly: a repository is expected to throw
/// [Failure], but a bug that throws something else should degrade to a generic
/// message rather than crash the screen.
String messageOf(Object error) {
  if (error is Failure) return error.userMessage;
  return 'Something went wrong. Please try again.';
}
