import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';

class ErrorScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const ErrorScreen({
    super.key,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.safeMargin),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 64.0, useGlassmorphism: true),
                const SizedBox(height: AppConstants.stackLg),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.stackLg),
                  decoration: BoxDecoration(
                    color: const Color(0xB3122131),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: const Color(0x33FFB4AB),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 56,
                        color: Color(0xFFFFB4AB),
                      ),
                      const SizedBox(height: AppConstants.stackMd),
                      const Text(
                        AppStrings.errorTitle,
                        style: TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.stackSm),
                      Text(
                        errorMessage ?? AppStrings.defaultErrorMessage,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 14,
                          color: AppConstants.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.stackMd),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildErrorChip(Icons.warning_amber_rounded, 'Network Timeout'),
                          _buildErrorChip(Icons.report_problem_rounded, 'HTTP Error'),
                          _buildErrorChip(Icons.build_circle_rounded, 'Auto Retry Available'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.stackLg),

                AppButton(
                  text: AppStrings.btnReload,
                  icon: Icons.refresh,
                  variant: AppButtonVariant.primary,
                  onPressed: onRetry ??
                      () {
                        Navigator.of(context).maybePop();
                      },
                ),
                const SizedBox(height: AppConstants.stackSm),
                AppButton(
                  text: AppStrings.btnGoBack,
                  icon: Icons.arrow_back,
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed(AppRoutes.splash);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x33FFB4AB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0x66FFB4AB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFFFB4AB)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.heading,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFB4AB),
            ),
          ),
        ],
      ),
    );
  }
}
