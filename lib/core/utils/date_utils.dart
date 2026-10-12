import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _keyFormatter = DateFormat('yyyy-MM-dd');

  /// Convert DateTime to standard storage date key "YYYY-MM-DD"
  static String toDateKey(DateTime date) {
    return _keyFormatter.format(date);
  }

  /// Parse standard date key string "YYYY-MM-DD" into DateTime
  static DateTime parseDateKey(String key) {
    return _keyFormatter.parse(key);
  }

  /// Returns DateTime with time truncated to 00:00:00
  static DateTime normalize(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Checks if two DateTimes fall on the exact same calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Format date for clean UI header display e.g. "Thursday, Jul 30"
  static String formatHeaderDate(DateTime date) {
    return DateFormat('EEEE, MMM d').format(date);
  }

  /// Format short day label e.g. "Thu"
  static String formatDayName(DateTime date) {
    return DateFormat('E').format(date);
  }
}
