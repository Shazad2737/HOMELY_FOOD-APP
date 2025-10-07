import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            title: Text('Hi, Antoine', style: AppTextStyles.titleLarge),
            pinned: true,
            backgroundColor: AppColors.white,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDims.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PromoBannerCard(
                    title: 'Desoan',
                    subtitle: 'Enjoy the flavours of delicious dishes',
                    buttonLabel: 'ORDER NOW',
                    onPressed: () {},
                    image: appImages.appLogo.image(height: 96),
                  ),
                  const SizedBox(height: 16),
                  Text('Food Categories', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final selected = index == 0;
                        return CategoryChip(
                          label: index == 0
                              ? 'Authentic Food'
                              : index == 1
                              ? 'Diet Food'
                              : 'Natural Food',
                          selected: selected,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.grey100,
                            child: Text('${index + 1}'),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: PromoBannerCard(
                          title: '50% OFF',
                          subtitle: 'Order Burger Favourite',
                          onPressed: () {},
                          buttonLabel: 'Order now',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PromoBannerCard(
                          title: 'Invite Your Friends',
                          subtitle: 'Get free popcorn and pepsi',
                          onPressed: () {},
                          buttonLabel: 'Invite Now',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PromoBannerCard(
                    title: 'Get 60% Discount Now',
                    subtitle: 'Exclusive seasonal fruits',
                    onPressed: () {},
                    buttonLabel: 'Order now',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
