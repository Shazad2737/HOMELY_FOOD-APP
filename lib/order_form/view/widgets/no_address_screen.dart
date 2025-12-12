import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:homely_app/router/router.gr.dart';

/// {@template no_address_screen}
/// Screen shown when user tries to access order form without any saved address
/// {@endtemplate}
class NoAddressScreen extends StatelessWidget {
  /// {@macro no_address_screen}
  const NoAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Delivery Address',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please add a delivery address before placing an order. We need to know where to deliver your delicious meals!',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Add Delivery Address',
                onPressed: () {
                  context.router.push(AddressFormRoute());
                },
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                context.router.maybePop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
