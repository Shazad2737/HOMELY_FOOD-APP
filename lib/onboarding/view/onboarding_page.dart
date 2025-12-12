import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/onboarding/bloc/onboarding_bloc.dart';
import 'package:instamess_app/onboarding/view/widgets/widgets.dart';
import 'package:instamess_app/router/router.gr.dart';

/// Data model for onboarding page content.
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.image,
  });

  final String title;
  final String description;
  final ImageProvider image;
}

/// List of onboarding pages content.
List<OnboardingPageData> _getPages() => [
  OnboardingPageData(
    title: 'Subscription',
    description:
        'Customer can subscribe our different kinds of meal plans '
        'according to their wish.',
    image: appImages.onboarding1.provider(),
  ),
  OnboardingPageData(
    title: 'Orders',
    description:
        'After the subscription, select the preferred meals from the '
        'menu and place the orders using order form.',
    image: appImages.onboarding2.provider(),
  ),
  OnboardingPageData(
    title: 'Meal preparation',
    description:
        'We will prepare your meals as per the order and pack it for '
        'delivery.',
    image: appImages.onboarding3.provider(),
  ),
  OnboardingPageData(
    title: 'Delivery',
    description:
        "Our delivery partner will deliver the order to the customer's "
        'location.',
    image: appImages.onboarding4.provider(),
  ),
];

/// {@template onboarding_page}
/// Onboarding screen shown to first-time users.
/// {@endtemplate}
@RoutePage()
class OnboardingPage extends StatelessWidget {
  /// {@macro onboarding_page}
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingBloc(
        onboardingRepository: context.read<IOnboardingRepository>(),
      ),
      child: const OnboardingView(),
    );
  }
}

/// Main view for the onboarding screen.
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final PageController _pageController;
  late final List<OnboardingPageData> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = _getPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.isCompleted) {
          context.router.replaceAll([const LoginRoute()]);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Hero image area with PageView
                Expanded(
                  flex: 5,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      context.read<OnboardingBloc>().add(
                        OnboardingPageChangedEvent(page: index),
                      );
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 24,
                          ),
                          child: SizedBox(
                            height: 200,
                            child: Image(
                              image: _pages[index].image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Orange card with content - fixed at bottom
                Expanded(
                  flex: 4,
                  child: OnboardingCard(
                    title: _pages[state.currentPage].title,
                    description: _pages[state.currentPage].description,
                    currentPage: state.currentPage,
                    totalPages: state.totalPages,
                    isLastPage: state.isLastPage,
                    isLoading: state.isCompleting,
                    onGetStarted: () {
                      context.read<OnboardingBloc>().add(
                        OnboardingCompletedEvent(),
                      );
                    },
                    onNext: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    onBack: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
