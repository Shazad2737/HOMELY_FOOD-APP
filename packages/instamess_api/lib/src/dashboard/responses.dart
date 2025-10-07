// {
//     "todaysExpense": 0,
//     "thisWeeksExpense": 0,
//     "thisMonthsExpense": 4500,
//     "todaysIncome": 0,
//     "thisWeeksIncome": 0,
//     "thisMonthsIncome": 0,
//     "inHandCash": 0
// }

// ignore_for_file: public_member_api_docs

import 'package:core/core.dart';

/// Response from the server for the dashboard.
class DashboardResponse extends Model {
  DashboardResponse({
    required this.todaysExpense,
    required this.thisWeeksExpense,
    required this.thisMonthsExpense,
    required this.todaysIncome,
    required this.thisWeeksIncome,
    required this.thisMonthsIncome,
    required this.inHandCash,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      todaysExpense: (json['todaysExpense'] as num).toDouble(),
      thisWeeksExpense: (json['thisWeeksExpense'] as num).toDouble(),
      thisMonthsExpense: (json['thisMonthsExpense'] as num).toDouble(),
      todaysIncome: (json['todaysIncome'] as num).toDouble(),
      thisWeeksIncome: (json['thisWeeksIncome'] as num).toDouble(),
      thisMonthsIncome: (json['thisMonthsIncome'] as num).toDouble(),
      inHandCash: (json['inHandCash'] as num).toDouble(),
    );
  }
  final double todaysExpense;
  final double thisWeeksExpense;
  final double thisMonthsExpense;
  final double todaysIncome;
  final double thisWeeksIncome;
  final double thisMonthsIncome;
  final double inHandCash;

  @override
  Map<String, dynamic> toJson() {
    return {
      'todaysExpense': todaysExpense,
      'thisWeeksExpense': thisWeeksExpense,
      'thisMonthsExpense': thisMonthsExpense,
      'todaysIncome': todaysIncome,
      'thisWeeksIncome': thisWeeksIncome,
      'thisMonthsIncome': thisMonthsIncome,
      'inHandCash': inHandCash,
    };
  }
}
