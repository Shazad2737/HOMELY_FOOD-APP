import 'package:homely_api/src/user/models/models.dart' as user_models;
import 'package:homely_app/order_form/bloc/order_form_bloc.dart';
import 'package:intl/intl.dart';

/// Helper class for calculating next available date information
class NextAvailableDateCalculator {
  const NextAvailableDateCalculator._();

  /// Get information about the next available date for ordering
  ///
  /// For repeat orders, this intelligently suggests the date AFTER the
  /// currently selected date, ensuring the repeat flow makes sense to users.
  /// This prevents counter-intuitive suggestions like repeating a Nov 12 order
  /// for Nov 9 (which is before the ordered date and may have no meals).
  static ({String date, String label, bool canRepeat}) calculate(
    OrderFormState state,
  ) {
    // Compute search start date first (so we can fall back to it if needed)
    final now = DateTime.now();

    DateTime searchStartDate;
    if (state.selectedDate != null) {
      try {
        final selectedDateTime = DateTime.parse(state.selectedDate!);
        searchStartDate = selectedDateTime.add(const Duration(days: 1));
      } catch (_) {
        searchStartDate = now.add(const Duration(days: 1));
      }
    } else {
      searchStartDate = now.add(const Duration(days: 1));
    }

    final availableDays = state.availableDaysState.maybeMap(
      success: (s) => s.data.days,
      refreshing: (r) => r.currentData.days,
      orElse: () => <user_models.OrderDay>[],
    );

    // If there are no days provided by the backend, return the search start
    // date as a sensible fallback and mark that we cannot repeat.
    if (availableDays.isEmpty) {
      final fallbackDate = _formatDateString(searchStartDate);
      final fallbackLabel =
          _isSameDay(searchStartDate, now.add(const Duration(days: 1)))
          ? 'Tomorrow'
          : DateFormat('MMM d').format(searchStartDate);

      return (
        date: fallbackDate,
        label: fallbackLabel,
        canRepeat: false,
      );
    }

    for (var i = 0; i <= 30; i++) {
      // Check up to 30 days from the start date
      final checkDate = searchStartDate.add(Duration(days: i));
      final dateStr = _formatDateString(checkDate);

      final day = _findDayByDate(availableDays, dateStr);

      if (day != null &&
          day.isAvailable &&
          !day.alreadyOrdered &&
          day.holidayName == null &&
          _hasMealOptions(day)) {
        // Found an available date with meal options
        final isTomorrow = _isSameDay(
          checkDate,
          now.add(const Duration(days: 1)),
        );

        final label = isTomorrow
            ? 'Tomorrow'
            : DateFormat('MMM d').format(checkDate);

        return (
          date: dateStr,
          label: label,
          canRepeat: true,
        );
      }
    }

    // Fallback: return the search start date even if not available
    final fallbackDate = _formatDateString(searchStartDate);
    final fallbackLabel =
        _isSameDay(searchStartDate, now.add(const Duration(days: 1)))
        ? 'Tomorrow'
        : DateFormat('MMM d').format(searchStartDate);

    return (
      date: fallbackDate,
      label: fallbackLabel,
      canRepeat: false,
    );
  }

  static bool _hasMealOptions(user_models.OrderDay day) {
    // Ensure at least one meal type is both available and has food items
    final a = day.availableMealTypes;
    final f = day.foodItems;

    if (a.breakfast && f.breakfast.isNotEmpty) return true;
    if (a.lunch && f.lunch.isNotEmpty) return true;
    if (a.dinner && f.dinner.isNotEmpty) return true;
    return false;
  }

  static String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static user_models.OrderDay? _findDayByDate(
    List<user_models.OrderDay> days,
    String dateStr,
  ) {
    try {
      return days.firstWhere((d) => d.date == dateStr);
    } catch (e) {
      return null;
    }
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
