import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:core/core.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/profile/terms/bloc/terms_cubit.dart';

@RoutePage()
class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TermsCubit(
        cmsRepository: ctx.read<ICmsRepository>(),
      )..loadTerms(),
      child: const _TermsAndConditionsView(),
    );
  }
}

class _TermsAndConditionsView extends StatelessWidget {
  const _TermsAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: BlocBuilder<TermsCubit, DataState<Terms>>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const Center(child: CircularProgressIndicator()),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            failure: (f) => _TermsErrorView(message: f.failure.message),
            success: (s) => RefreshIndicator(
              onRefresh: () async {
                await context.read<TermsCubit>().refreshTerms();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDims.screenPadding),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Html(data: s.data.termsAndConditions),
              ),
            ),
            refreshing: (r) => RefreshIndicator(
              onRefresh: () async {
                await context.read<TermsCubit>().refreshTerms();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDims.screenPadding),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Html(data: r.currentData.termsAndConditions),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TermsErrorView extends StatelessWidget {
  const _TermsErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(message, style: context.textTheme.bodyLarge),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<TermsCubit>().loadTerms(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
