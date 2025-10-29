import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:instamess_app/subscriptions/view/widgets/contact_button.dart';
import 'package:instamess_app/subscriptions/view/widgets/promotional_banner.dart';
import 'package:instamess_app/subscriptions/view/widgets/subscription_card.dart';

@RoutePage()
class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // Title
                Center(
                  child: Text(
                    'Subscription',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Center(
                  child: Text(
                    'Your Current Subscription is listed below',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 32),

                // Subscription Cards
                const SubscriptionCard(
                  title: 'Breakfast',
                  dateRange: '02-December-2025 - 01-January-2026',
                ),

                const SizedBox(height: 16),

                const SubscriptionCard(
                  title: 'Lunch',
                  dateRange: '02-December-2025 - 01-January-2026',
                ),

                const SizedBox(height: 16),

                const SubscriptionCard(
                  title: 'Dinner',
                  dateRange: '02-December-2025 - 01-January-2026',
                ),

                const SizedBox(height: 32),

                // Promotional Banner
                const PromotionalBanner(),

                const SizedBox(height: 32),

                // Contact Buttons
                ContactButton(
                  icon: Brand(Brands.whatsapp),
                  text: 'Contact Via WhatsApp',
                  color: const Color(0xff25D366),
                ),
                const SizedBox(height: 16),
                const ContactButton(
                  icon: Icon(
                    Icons.phone,
                    color: AppColors.white,
                  ),
                  text: 'Contact Via Phone',
                  color: AppColors.appRed,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
