import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool useGlassmorphism;

  const AppLogo({
    super.key,
    this.size = 80.0,
    this.useGlassmorphism = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget iconContent = Container(
      width: size * 0.75,
      height: size * 0.75,
      padding: EdgeInsets.all(size * 0.08),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Center(
        child: Image.asset(
          AppAssets.appLogo,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.hub,
            size: size * 0.32,
            color: AppConstants.primaryColor,
          ),
        ),
      ),
    );

    if (!useGlassmorphism) {
      return iconContent;
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppConstants.primaryColor.withValues(alpha: 0.05),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(child: iconContent),
    );
  }
}
