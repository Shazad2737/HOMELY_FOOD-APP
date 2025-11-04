import 'package:intl/intl.dart';

/// Utility class for date formatting in order form
class OrderFormDateFormatter {
  const OrderFormDateFormatter._();

  /// Get day name from weekday number (1-7, Monday-Sunday)
  static String getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  /// Get short day name from weekday number (1-7, Monday-Sunday)
  static String getShortDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Get month name from month number (1-12)
  static String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Get short month name from month number (1-12)
  static String getShortMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Format date for selected date display (e.g., "Monday, January 5, 2025")
  static String formatSelectedDate(DateTime date) {
    final dayName = getDayName(date.weekday);
    final monthName = getMonthName(date.month);
    return '$dayName, $monthName ${date.day}, ${date.year}';
  }

  /// Format date for compact display (e.g., "Mon, Jan 5")
  static String formatCompactDate(DateTime date) {
    final dayName = getShortDayName(date.weekday);
    final monthName = getShortMonthName(date.month);
    return '$dayName, $monthName ${date.day}';
  }

  /// Format order date (e.g., "for Mon, Jan 5")
  static String formatOrderDate(DateTime date) {
    return 'for ${formatCompactDate(date)}';
  }

  /// Format full order date (e.g., "January 5, 2025")
  static String formatFullOrderDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('MMMM d, yyyy').format(date);
    } catch (e) {
      return isoDate;
    }
  }
}
