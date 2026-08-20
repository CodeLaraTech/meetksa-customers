import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../logic/splash_controller.dart';
import '../widgets/splash_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final SplashController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplashController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initializeAndNavigate(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: NetworkGridBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.safeMargin,
              vertical: AppConstants.stackLg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: AppConstants.stackLg),

                // Top Logo Section
                const Hero(
                  tag: AppStrings.heroAppLogo,
                  child: AppLogo(size: 110.0, useGlassmorphism: true),
                ),

                // Middle Section: Headline, Subtitle & Feature Badges
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppConstants.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.stackSm),
                    const Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 16.0,
                        color: AppConstants.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.stackLg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeaturePill(Icons.bolt_rounded, 'Fast Shell'),
                        const SizedBox(width: 8),
                        _buildFeaturePill(Icons.shield_outlined, 'TLS 1.3 Secure'),
                        const SizedBox(width: 8),
                        _buildFeaturePill(Icons.cloud_done_rounded, 'Cloud Sync'),
                      ],
                    ),
                  ],
                ),

                // Bottom Section: Footer text & High-End Network Loader
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppConstants.appFooter,
                      style: TextStyle(
                        fontFamily: AppFonts.heading,
                        fontSize: 11.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppConstants.outlineColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppConstants.stackMd),
                    AppLoadingProgressIndicator(width: 192.0, height: 2.0),
                    SizedBox(height: AppConstants.stackSm),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppConstants.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppConstants.secondaryAccent),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppConstants.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
