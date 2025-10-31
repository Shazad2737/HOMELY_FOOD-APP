import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/src/cms/models/banner.dart' as api_models;
import 'package:instamess_app/home/view/widgets/promo/promo.dart';
import 'package:instamess_app/router/utils/banner_navigation_handler.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// A carousel widget that displays multiple promotional banner cards with page indicators.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    required this.banners,
    super.key,
    this.height = 120,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.enableInfiniteScroll = true,
    this.viewportFraction = 1.0,
    this.onPageChanged,
    this.showPageIndicatorInside = false,
  });

  final List<api_models.Banner> banners;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enableInfiniteScroll;
  final double viewportFraction;
  final void Function(int, CarouselPageChangedReason)? onPageChanged;

  final bool showPageIndicatorInside;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            height: widget.height,
            autoPlay: widget.autoPlay,
            autoPlayInterval: widget.autoPlayInterval,
            enableInfiniteScroll: widget.enableInfiniteScroll,
            viewportFraction: widget.viewportFraction,
            onPageChanged: (int index, CarouselPageChangedReason reason) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index, reason);
            },
          ),
          items: widget.banners.map((banner) {
            return Builder(
              builder: (BuildContext context) {
                // Use first image from banner if available
                final firstImage = banner.images.isNotEmpty
                    ? banner.images.first
                    : null;
                final imageUrl = firstImage?.imageUrl ?? '';
                final redirectUrl = firstImage?.redirectUrl;

                return PromoBannerCard(
                  promoBanner: PromoBanner(
                    imageUrl: imageUrl,
                    onTap: redirectUrl != null && redirectUrl.isNotEmpty
                        ? () {
                            BannerNavigationHandler.handleBannerTap(
                              context.router,
                              redirectUrl,
                            );
                          }
                        : null,
                  ),
                );
              },
            );
          }).toList(),
        ),
        if (widget.showPageIndicatorInside)
          Positioned(
            bottom: 12,
            child: AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: widget.banners.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                dotColor: AppColors.white,
                activeDotColor: AppColors.grey800,
              ),
              onDotClicked: _carouselController.animateToPage,
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: widget.banners.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                dotColor: AppColors.white,
                activeDotColor: AppColors.grey800,
              ),
              onDotClicked: _carouselController.animateToPage,
            ),
          ),
      ],
    );
  }
}
