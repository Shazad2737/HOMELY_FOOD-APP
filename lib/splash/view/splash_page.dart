import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homely_app/auth/bloc/auth_bloc.dart';
import 'package:homely_app/router/router.gr.dart';

/// Animated splash screen with logo bounce and text fade-in.
@RoutePage()
class SplashPage extends StatefulWidget {
  /// Creates a [SplashPage].
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  static const _tagline = 'The taste that feels like home food.';
  static const _logoAnimationDuration = Duration(milliseconds: 1000);
  static const _textAnimationDuration = Duration(milliseconds: 1500);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: _logoAnimationDuration,
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.7,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.95,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_logoController);

    _textController = AnimationController(
      vsync: this,
      duration: _textAnimationDuration,
    );

    _textOpacityAnimation = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );
  }

  bool _animationsComplete = false;

  Future<void> _startAnimationSequence() async {
    // Start logo animation
    _logoController.forward();

    // Start text animation 500ms into logo animation (overlapping)
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Wait for both animations to complete
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      _animationsComplete = true;
      // Check current auth state and navigate
      final authState = context.read<AuthBloc>().state;
      _navigateBasedOnAuthState(authState);
    }
  }

  void _handleAuthStateChange(BuildContext context, AuthState state) {
    // Only navigate if animations are complete
    if (_animationsComplete) {
      _navigateBasedOnAuthState(state);
    }
  }

  void _navigateBasedOnAuthState(AuthState state) {
    if (state is Authenticated) {
      context.router.replaceAll([const MainShellRoute()]);
    } else if (state is Unauthenticated) {
      context.router.replaceAll([const LoginRoute()]);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleAuthStateChange,
      child: _buildSplashContent(),
    );
  }

  Widget _buildSplashContent() {
    return Scaffold(
      backgroundColor: AppColors.appOrange,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _logoScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: appImages.appLogo.image(
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: AnimatedBuilder(
                animation: _textOpacityAnimation,
                builder: (context, child) {
                  return _AnimatedTagline(
                    text: _tagline,
                    progress: _textOpacityAnimation.value,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTagline extends StatelessWidget {
  const _AnimatedTagline({
    required this.text,
    required this.progress,
  });

  final String text;
  final double progress;

  @override
  Widget build(BuildContext context) {
    // Split into words and find the longest word length
    final words = text.split(' ');
    final maxWordLength = words.fold<int>(
      0,
      (max, word) => word.length > max ? word.length : max,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int wordIndex = 0; wordIndex < words.length; wordIndex++) ...[
          // Add space between words (except before first word)
          if (wordIndex > 0)
            Text(
              ' ',
              style: GoogleFonts.inter(
                color: AppColors.white.withValues(alpha: progress),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          // Build each word with staggered letter animation
          for (
            int charIndex = 0;
            charIndex < words[wordIndex].length;
            charIndex++
          )
            Text(
              words[wordIndex][charIndex],
              style: GoogleFonts.inter(
                // Animation based on character position within the word
                // All first letters fade together, then all second letters, etc.
                color: AppColors.white.withValues(
                  alpha: (progress * maxWordLength - charIndex).clamp(0.0, 1.0),
                ),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ],
    );
  }
}
