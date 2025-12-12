import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:homely_api/homely_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// {@template no_subscription_screen}
/// Screen shown when user tries to access order form without an active
/// subscription. Guides users to contact admin via WhatsApp to subscribe.
/// {@endtemplate}
class NoSubscriptionScreen extends StatelessWidget {
  /// {@macro no_subscription_screen}
  const NoSubscriptionScreen({
    this.subscriptionData,
    super.key,
  });

  /// Subscription data containing contact information
  final SubscriptionData? subscriptionData;

  @override
  Widget build(BuildContext context) {
    final whatsappNumber = subscriptionData?.contact.whatsapp;
    final phoneNumber = subscriptionData?.contact.phone;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Subscription',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You need an active subscription to place orders. '
              'Please visit the Subscriptions tab to view available plans '
              'or contact our team to get started.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Go to Subscriptions',
                onPressed: () {
                  // Navigate to Subscriptions tab (index 3 in MainShell)
                  final tabsRouter = AutoTabsRouter.of(context);
                  tabsRouter.setActiveIndex(3);
                },
              ),
            ),
            if (whatsappNumber != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _launchWhatsApp(context, whatsappNumber),
                  icon: Brand(Brands.whatsapp),
                  label: const Text('Contact via WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xff25D366)),
                    foregroundColor: const Color(0xff25D366),
                  ),
                ),
              ),
            ],
            if (phoneNumber != null && whatsappNumber == null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _launchPhone(context, phoneNumber),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Us'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    final formattedPhone = phone.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse('https://wa.me/$formattedPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }
}
