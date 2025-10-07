import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

abstract class AppDateUtils {
  static String getMonthName(DateTime date) {
    return DateFormat.MMM().format(date);
  }

  static List<String> getMonthList() {
    return List.generate(
      12,
      (index) => DateFormat.MMM().format(DateTime(2021, index + 1)),
    );
  }

  static List<String> getMonthListUptoCurrentMonth() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    return List.generate(
      12,
      (index) {
        final dateTime = DateTime(year, month - index);
        // if (dateTime.year == year) {
        return DateFormat.MMM().format(dateTime);
        // } else {
        //   return DateFormat.yMMM().format(dateTime);
        // }
      },
    );
  }

  /// Returns the formatted date in MMM dd, yyyy format
  /// Example: Jan 01, 2021
  static String getFormattedDateMMMddyyyy(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  /// Returns the formatted date in MMM dd format
  /// Example: Jan 01
  static String getFormattedDateMMMdd(DateTime date) {
    return DateFormat.MMMd().format(date);
  }

  /// Returns the formatted time in h:mm format
  /// Example: 1:00
  static String getFormattedTimeOnly(DateTime date) {
    return DateFormat('h:mm').format(date);
  }

  /// Returns the formatted time in h:mm a format
  /// Example: 1:00 PM
  static String getFormattedTime(DateTime date) {
    return DateFormat.jm().format(date);
  }

  static String? getAmPm(DateTime? date) {
    if (date == null) return null;
    if (date.hour < 12) {
      return 'AM';
    } else {
      return 'PM';
    }
  }

  static String? formatTimeOfDay(TimeOfDay? date) {
    if (date == null) return null;
    return DateFormat.jm().format(DateTime(2021, 1, 1, date.hour, date.minute));
  }

  static String getFormattedDateTime(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  static String getFormattedDateTimeWithoutYear(DateTime date) {
    return DateFormat.MMMd().add_jm().format(date);
  }
}

extension DateUtilsExtension on DateTime {
  /// Returns the month name of this date
  String get monthName => AppDateUtils.getMonthName(this);

  /// Returns the formatted date in MMM dd, yyyy format
  ///
  /// Example: Jan 01, 2021
  String get formattedDateMMMddyyyy =>
      AppDateUtils.getFormattedDateMMMddyyyy(this);

  /// Returns the formatted date in MMM dd format
  ///
  /// Example: Jan 01
  String get formattedDateMMMdd => AppDateUtils.getFormattedDateMMMdd(this);

  /// Returns the formatted time in h:mm format
  ///
  /// Example: 1:00
  String get formattedTimeOnly => AppDateUtils.getFormattedTimeOnly(this);

  /// Returns the formatted time in h:mm a format
  /// Example: 1:00 PM
  String get formattedTime => AppDateUtils.getFormattedTime(this);

  /// Returns the AM/PM of this date
  ///
  /// Example: AM
  String? get amPm => AppDateUtils.getAmPm(this);

  /// Returns the formatted date and time in MMM dd, yyyy h:mm a format,
  ///
  /// Example: Jan 01, 2021 1:00 PM
  String get formattedDateTime => AppDateUtils.getFormattedDateTime(this);

  /// Returns the formatted date and time in MMM dd h:mm a format,
  ///
  /// Example: Jan 01 1:00 PM
  String get formattedDateTimeWithoutYear =>
      AppDateUtils.getFormattedDateTimeWithoutYear(this);

  /// Combines this date with the given [timeOfDay] into a single DateTime
  /// object in UTC.
  DateTime combineWithTimeOfDay(TimeOfDay timeOfDay) {
    return combineDateTimeAndTimeOfDay(this, timeOfDay);
  }

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  DateTime get startOfMonth => DateTime(year, month);

  DateTime get endOfMonth => DateTime(year, month + 1, 0);
}

/// Combines the given [dateTimeLocal] and [timeOfDayLocal] into a single
/// DateTime object in UTC.
///
/// If the combined local DateTime is before the original local DateTime,
/// it means the timeOfDayLocal is for the next day (after midnight scenario).
/// In this case, the combined local DateTime is incremented by 1 day.
DateTime combineDateTimeAndTimeOfDay(
  DateTime dateTimeLocal,
  TimeOfDay timeOfDayLocal,
) {
  // Create a new DateTime in the local time zone with the same date and the given time
  final combinedDateTimeLocal = DateTime(
    dateTimeLocal.year,
    dateTimeLocal.month,
    dateTimeLocal.day,
    timeOfDayLocal.hour,
    timeOfDayLocal.minute,
  );

  // Check if the new local DateTime is before the original local DateTime
  // If yes, it means the timeOfDayLocal is for the next day (after midnight scenario)
  // if (combinedDateTimeLocal.isBefore(dateTimeLocal)) {
  //   combinedDateTimeLocal = combinedDateTimeLocal.add(const Duration(days: 1));
  // }

  // Convert the combined local DateTime back to UTC
  final combinedDateTimeUtc = combinedDateTimeLocal.toUtc();

  return combinedDateTimeUtc;
}
