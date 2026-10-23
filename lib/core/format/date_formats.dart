import 'package:intl/intl.dart';

/// Human-readable date and time formatting.
///
/// Kept in `core/` so the feed, the detail screen, and later the admin editor
/// all render schedules identically.
abstract final class DateFormats {
  const DateFormats._();

  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _dayShort = DateFormat('EEE, MMM d');
  static final DateFormat _dayLong = DateFormat('MMM d, y');
  static final DateFormat _monthDay = DateFormat('MMM d');
  static final DateFormat _fullDay = DateFormat('EEEE, MMMM d, y');

  /// `Sat, Nov 8 · 9:00 AM – 5:00 PM`, or a date range when it spans days.
  static String schedule(DateTime start, DateTime end) {
    final sameDay =
        start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;

    if (sameDay) {
      return '${_dayShort.format(start)} · '
          '${_time.format(start)} – ${_time.format(end)}';
    }

    final sameYear = start.year == end.year;
    return sameYear
        ? '${_monthDay.format(start)} – ${_dayLong.format(end)}'
        : '${_dayLong.format(start)} – ${_dayLong.format(end)}';
  }

  /// Absolute date for the detail screen header, e.g. `Saturday, November 8, 2026`.
  static String fullDate(DateTime date) => _fullDay.format(date);

  /// Short relative label for feed badges: `Today`, `Tomorrow`, or `In 5 days`.
  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final days = target.difference(today).inDays;

    return switch (days) {
      0 => 'Today',
      1 => 'Tomorrow',
      < 0 => 'Past',
      <= 6 => 'In $days days',
      _ => _monthDay.format(date),
    };
  }
}
