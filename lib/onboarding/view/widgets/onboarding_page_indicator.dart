import 'package:flutter/material.dart';

/// {@template onboarding_page_indicator}
/// Dot indicator showing current page position.
/// {@endtemplate}
class OnboardingPageIndicator extends StatelessWidget {
  /// {@macro onboarding_page_indicator}
  const OnboardingPageIndicator({
    required this.currentPage,
    required this.totalPages,
    super.key,
  });

  /// Current page index.
  final int currentPage;

  /// Total number of pages.
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
