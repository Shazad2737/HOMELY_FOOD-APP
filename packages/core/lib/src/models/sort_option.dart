import 'package:equatable/equatable.dart';

class SortOption extends Equatable {
  const SortOption({
    required this.sortBy,
    required this.sortOrder,
  });

  final SortBy sortBy;
  final SortOrder sortOrder;

  SortOption copyWith({
    SortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return SortOption(
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// toggles the sort order from asc to desc and vice versa
  SortOption toggleSortOrder() {
    return SortOption(
      sortBy: sortBy,
      sortOrder: sortOrder == SortOrder.asc ? SortOrder.desc : SortOrder.asc,
    );
  }

  @override
  List<Object> get props => [sortBy, sortOrder];
}

enum SortBy {
  // name,
  // type,
  date,
}

enum SortOrder {
  asc,
  desc,
}
