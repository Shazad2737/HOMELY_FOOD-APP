import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Widget that displays the [SortBy] options (e.g. date, amount, etc.)
class SortByOptions extends StatelessWidget {
  const SortByOptions({
    required this.onSortByChanged,
    required this.selectedSortBy,
    super.key,
  });

  /// Callback for when the sort option is changed
  ///
  /// The [selectedSortBy] is the newly selected sort option
  ///
  /// The [isSelected] is a boolean that indicates if the sort option is
  /// selected or deselected
  final ValueChanged<
      ({
        SortBy selectedSortBy,
        bool isSelected,
      })> onSortByChanged;

  final SortBy? selectedSortBy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SortBy.values
          .map(
            (e) => FilterChip(
              label: Text(
                e.name.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              selected: selectedSortBy == e,
              // backgroundColor: AppColors.base100,
              // selectedColor: AppColors.base100.withOpacity(0.8),
              onSelected: (selected) {
                onSortByChanged(
                  (
                    selectedSortBy: e,
                    isSelected: selected,
                  ),
                );
              },
            ),
          )
          .toList(),
    );
  }
}
