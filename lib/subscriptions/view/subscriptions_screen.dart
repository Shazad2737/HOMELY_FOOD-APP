import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/subscriptions/bloc/subscriptions_bloc.dart';
import 'package:instamess_app/subscriptions/view/widgets/contact_button.dart';
import 'package:instamess_app/subscriptions/view/widgets/promotional_banner.dart';
import 'package:instamess_app/subscriptions/view/widgets/subscription_card.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionsBloc(
        userRepository: context.read<IUserRepository>(),
      )..add(SubscriptionsLoadedEvent()),
      child: const _SubscriptionsScreenContent(),
    );
  }
}

class _SubscriptionsScreenContent extends StatelessWidget {
  const _SubscriptionsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<SubscriptionsBloc>().add(
                SubscriptionsRefreshedEvent(),
              );
              await context.read<SubscriptionsBloc>().stream.firstWhere(
                (s) => !s.isRefreshing,
              );
            },
            child: CustomScrollView(
              slivers: [
                const _HeaderSection(),
                _ContentSection(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                'Subscription',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your Current Subscription is listed below',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.state});

  final SubscriptionsState state;

  @override
  Widget build(BuildContext context) {
    return state.subscriptionState.map(
      initial: (_) => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      loading: (_) => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      success: (s) => _SuccessContent(data: s.data),
      failure: (f) => _ErrorContent(failure: f.failure),
      refreshing: (r) => _SuccessContent(data: r.currentData),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  context.read<SubscriptionsBloc>().add(
                    SubscriptionsLoadedEvent(),
                  );
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.data});

  final SubscriptionData data;

  @override
  Widget build(BuildContext context) {
    final subscribed = data.subscribedMeals;
    final available = data.availableMeals;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscribed Meal Types
            if (subscribed.isNotEmpty)
              ...subscribed.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SubscriptionCard(
                    title: m.name,
                    dateRange: m.formattedDateRange ?? 'Active',
                  ),
                ),
              ),

            // Available Meal Types
            if (available.isNotEmpty) ...[
              if (subscribed.isNotEmpty) const SizedBox(height: 8),
              ...available.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SubscriptionCard(
                    title: m.name,
                    dateRange: 'Available for subscription',
                    isSubscribed: false,
                  ),
                ),
              ),
            ],

            if (subscribed.isEmpty && available.isEmpty) ...[
              const SizedBox(height: 48),
              Center(
                child: Text(
                  'No subscriptions available',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],

            const SizedBox(height: 16),

            if (data.banner != null && data.banner!.images.isNotEmpty) ...[
              PromotionalBanner(banner: data.banner!),
              const SizedBox(height: 32),
            ],

            if (data.contact.whatsapp != null) ...[
              ContactButton(
                icon: Brand(Brands.whatsapp),
                text: 'Contact Via WhatsApp',
                color: const Color(0xff25D366),
                onTap: () =>
                    _launchWhatsApp(context, data.contact.whatsapp ?? ''),
              ),
              const SizedBox(height: 16),
            ],
            if (data.contact.phone != null) ...[
              ContactButton(
                icon: const Icon(Icons.phone, color: AppColors.white),
                text: 'Contact Via Phone',
                color: AppColors.appRed,
                onTap: () => _launchPhone(context, data.contact.phone ?? ''),
              ),

              const SizedBox(height: 30),
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
