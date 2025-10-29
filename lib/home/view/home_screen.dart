import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/home/bloc/home_bloc.dart';
import 'package:instamess_app/home/view/widgets/categories/categories_section.dart';
import 'package:instamess_app/home/view/widgets/promo/promo.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(
        cmsFacade: context.read<ICmsRepository>(),
      )..add(HomeLoadedEvent()),
      child: const _HomeScreenContent(),
    );
  }
}

class _HomeScreenContent extends StatelessWidget {
  const _HomeScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(HomeRefreshedEvent());
              await context.read<HomeBloc>().stream.firstWhere(
                (state) => !state.isRefreshing,
              );
            },
            child: CustomScrollView(
              slivers: [
                _AppBarSection(state: state),
                _ContentSection(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AppBarSection extends StatelessWidget {
  const _AppBarSection({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final homePageData = state.homePageData;
    final hasUnreadNotifications =
        homePageData?.hasUnreadNotifications ?? false;

    return SliverAppBar(
      automaticallyImplyLeading: false,
      // TODO(bilal): Replace hard-coded name with actual user's first name when available
      title: Text('Hi, User', style: context.textTheme.titleLarge),
      pinned: true,
      centerTitle: false,
      backgroundColor: AppColors.white,
      actions: [
        Stack(
          children: [
            IconButton(
              onPressed: () {
                // TODO: Navigate to notifications
              },
              style: IconButton.styleFrom(
                foregroundColor: AppColors.appBarIcon,
              ),
              icon: const Icon(Icons.notifications_outlined),
            ),
            if (hasUnreadNotifications)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return state.homePageState.map(
      initial: (_) => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      loading: (_) => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      success: (successState) => _SuccessContent(data: successState.data),
      failure: (failureState) => _ErrorContent(failure: failureState.failure),
      refreshing: (refreshingState) =>
          _SuccessContent(data: refreshingState.currentData),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              failure.message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<HomeBloc>().add(HomeLoadedEvent());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.data});

  final HomePageData data;

  @override
  Widget build(BuildContext context) {
    final topBanners = data.getBannersByPlacement(
      BannerPlacement.homePageTop,
    );

    final middleBanner1 = data.getBannersByPlacement(
      BannerPlacement.homePageMiddle1,
    );

    final middleBanner2 = data.getBannersByPlacement(
      BannerPlacement.homePageMiddle2,
    );

    final bottomBanners = data.getBannersByPlacement(
      BannerPlacement.homePageBottom,
    );

    final hasContent =
        topBanners.isNotEmpty ||
        data.categories.isNotEmpty ||
        middleBanner1.isNotEmpty ||
        middleBanner2.isNotEmpty ||
        bottomBanners.isNotEmpty;

    if (!hasContent) {
      return const _EmptyContent();
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppDims.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (topBanners.isNotEmpty) ...[
              PromoCarousel(banners: topBanners),
              const SizedBox(height: 16),
            ],
            if (data.categories.isNotEmpty) ...[
              CategoriesSection(categories: data.categories),
              const Space(2),
            ],
            // Middle promo row (safe layout + presence checks)
            if (middleBanner1.isNotEmpty || middleBanner2.isNotEmpty) ...[
              Row(
                children: [
                  if (middleBanner1.isNotEmpty)
                    Expanded(
                      child: PromoBannerCard(
                        promoBanner: PromoBanner(
                          title: middleBanner1.first.title ?? '',
                          subtitle: middleBanner1.first.description ?? '',
                          image: middleBanner1.first.images.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      middleBanner1
                                          .first
                                          .images
                                          .first
                                          .imageUrl ??
                                      '',
                                  height: 96,
                                )
                              : null,
                          backgroundColor: AppColors.appRed,
                          buttonLabel: 'Order now',
                        ),
                      ),
                    ),
                  if (middleBanner1.isNotEmpty && middleBanner2.isNotEmpty)
                    const SizedBox(width: 16),
                  if (middleBanner2.isNotEmpty)
                    Expanded(
                      child: PromoBannerCard(
                        promoBanner: PromoBanner(
                          title: middleBanner2.first.title ?? '',
                          subtitle: middleBanner2.first.description ?? '',
                          image: middleBanner2.first.images.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl:
                                      middleBanner2
                                          .first
                                          .images
                                          .first
                                          .imageUrl ??
                                      '',
                                  height: 96,
                                )
                              : null,
                          backgroundColor: AppColors.appOrange,
                          buttonLabel: 'Invite Now',
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (bottomBanners.isNotEmpty) ...[
              PromoCarousel(
                banners: bottomBanners,
                height: 140,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 16),
            Text(
              'No content available',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for updates',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
