import 'package:equatable/equatable.dart';

/// {@template pagination}
/// Pagination information for notifications
/// {@endtemplate}
class Pagination extends Equatable {
  /// {@macro pagination}
  const Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  /// Parse from JSON
  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
    );
  }

  /// Current page number
  final int page;

  /// Number of items per page
  final int limit;

  /// Total number of items
  final int total;

  /// Total number of pages
  final int totalPages;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }

  @override
  List<Object?> get props => [page, limit, total, totalPages];
}
