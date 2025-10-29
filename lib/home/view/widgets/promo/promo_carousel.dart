import 'package:app_ui/app_ui.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/src/cms/models/banner.dart' as api_models;
import 'package:instamess_app/home/view/widgets/promo/promo.dart';
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
  });

  final List<api_models.Banner> banners;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enableInfiniteScroll;
  final double viewportFraction;
  final void Function(int, CarouselPageChangedReason)? onPageChanged;

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

    return Column(
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
                final imageUrl = banner.images.isNotEmpty == true
                    ? banner.images.first.imageUrl
                    : null;

                return PromoBannerCard(
                  promoBanner: PromoBanner(
                    title: banner.title ?? '',
                    subtitle: banner.description ?? '',
                    buttonLabel: 'ORDER NOW',
                    image: imageUrl != null
                        ? Image.network(imageUrl, height: 96)
                        : appImages.foodRound1.image(height: 96),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        AnimatedSmoothIndicator(
          activeIndex: _currentIndex,
          count: widget.banners.length,
          effect: const WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            dotColor: AppColors.grey300,
            activeDotColor: AppColors.grey600,
          ),
          onDotClicked: _carouselController.animateToPage,
        ),
      ],
    );
  }
}
