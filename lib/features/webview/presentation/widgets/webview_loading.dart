import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class WebViewLoadingProgressBar extends StatelessWidget {
  final int progress;

  const WebViewLoadingProgressBar({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    if (progress <= 0 || progress >= 100) {
      return const SizedBox.shrink();
    }

    final double factor = (progress / 100.0).clamp(0.0, 1.0);

    return Container(
      height: 3.0,
      width: double.infinity,
      color: AppConstants.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: factor,
          child: Container(
            decoration: const BoxDecoration(
              color: AppConstants.secondaryAccent,
              boxShadow: [
                BoxShadow(
                  color: Color(0x99009CA3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
