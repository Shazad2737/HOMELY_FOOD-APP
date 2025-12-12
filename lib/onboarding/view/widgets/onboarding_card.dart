import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:homely_app/onboarding/view/widgets/onboarding_page_indicator.dart';

/// {@template onboarding_card}
/// Orange card widget displaying onboarding content.
/// {@endtemplate}
class OnboardingCard extends StatelessWidget {
  /// {@macro onboarding_card}
  const OnboardingCard({
    required this.title,
    required this.description,
    required this.currentPage,
    required this.totalPages,
    required this.isLastPage,
    required this.isLoading,
    required this.onGetStarted,
    required this.onNext,
    required this.onBack,
    super.key,
  });

  /// Title text displayed on the card.
  final String title;

  /// Description text displayed on the card.
  final String description;

  /// Current page index for the indicator.
  final int currentPage;

  /// Total number of pages for the indicator.
  final int totalPages;

  /// Whether this is the last page.
  final bool isLastPage;

  /// Whether loading is in progress.
  final bool isLoading;

  /// Callback when Get Started is pressed.
  final VoidCallback onGetStarted;

  /// Callback when Next is pressed.
  final VoidCallback onNext;

  /// Callback when Back is pressed.
  final VoidCallback onBack;

  bool get _isFirstPage => currentPage == 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.appOrange,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            // Page indicator - always visible
            OnboardingPageIndicator(
              currentPage: currentPage,
              totalPages: totalPages,
            ),
            const SizedBox(height: 24),
            // Navigation buttons row
            if (isLastPage)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : onGetStarted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.appOrange,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.appOrange,
                          ),
                        )
                      : const Text(
                          'Get started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              )
            else
              // Back and Next buttons row - on opposite sides
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Subtle back button (only visible after first page)
                  if (!_isFirstPage)
                    IconButton(
                      onPressed: onBack,
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 22,
                      ),
                    )
                  else
                    const SizedBox(width: 48), // Placeholder for alignment
                  // Next button icon (filled)
                  SizedBox(
                    height: 52,
                    width: 52,
                    child: IconButton.filled(
                      onPressed: onNext,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.appOrange,
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 28),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
