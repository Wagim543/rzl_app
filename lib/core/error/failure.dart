/// A user-presentable error.
///
/// Everything thrown out of the data layer is normalised into one of these, so
/// the UI never has to know about `PostgrestException`, `SocketException`, or
/// any other transport-level type. `userMessage` is always safe to render.
sealed class Failure implements Exception {
  const Failure(this.userMessage, {this.cause, this.stackTrace});

  /// Short, non-technical message shown to the user.
  final String userMessage;

  /// Original error, kept for logging. Never rendered.
  final Object? cause;

  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $userMessage';
}

/// No connectivity, or the request timed out.
final class NetworkFailure extends Failure {
  const NetworkFailure({super.cause, super.stackTrace})
    : super('No connection. Check your network and try again.');
}

/// The backend is unreachable but the device has a connection.
final class ServerFailure extends Failure {
  const ServerFailure({super.cause, super.stackTrace})
    : super('The server is unavailable right now. Please try again.');
}

/// Sign-in, session, or credential problem.
final class AuthFailure extends Failure {
  const AuthFailure(super.userMessage, {super.cause, super.stackTrace});
}

/// Signed in, but the row-level security policy denied the operation.
final class PermissionFailure extends Failure {
  const PermissionFailure({super.cause, super.stackTrace})
    : super('You do not have permission to do that.');
}

/// The record was deleted or archived while it was being viewed.
final class NotFoundFailure extends Failure {
  const NotFoundFailure({super.cause, super.stackTrace})
    : super('That item is no longer available.');
}

/// A required table or function does not exist yet.
///
/// This is a configuration problem, not a user problem, so the message tells
/// the developer what to run.
final class SetupFailure extends Failure {
  const SetupFailure(super.userMessage, {super.cause, super.stackTrace});
}

/// Anything unclassified. Never shows the raw exception to the user.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.cause, super.stackTrace})
    : super('Something went wrong. Please try again.');
}
