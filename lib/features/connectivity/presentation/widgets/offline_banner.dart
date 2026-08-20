import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';

class OfflineScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const OfflineScreen({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Stack(
        children: [
          // Subtle node background texture
          Positioned.fill(
            child: Container(
              color: AppConstants.backgroundColor,
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.safeMargin,
                  vertical: AppConstants.stackLg,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo Glass Panel
                    const AppLogo(size: 64.0, useGlassmorphism: true),
                    const SizedBox(height: AppConstants.stackLg),

                    // Main Glass Card Illustration Panel
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppConstants.stackLg),
                      decoration: BoxDecoration(
                        color: const Color(0xB3122131), // Glass panel opacity
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(
                          color: AppConstants.secondaryAccent.withValues(alpha: 0.15),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Status Badge Pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppConstants.surfaceContainerHighest.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppConstants.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppConstants.secondaryAccent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x99009CA3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  AppStrings.systemOfflineBadge,
                                  style: TextStyle(
                                    fontFamily: AppFonts.heading,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                    color: AppConstants.secondaryAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppConstants.stackLg),

                          // Central Disconnect Circle
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConstants.surfaceContainerHighest.withValues(alpha: 0.3),
                              border: Border.all(
                                color: AppConstants.secondaryAccent.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppConstants.surfaceContainerLow.withValues(alpha: 0.6),
                                ),
                                child: const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 48,
                                  color: AppConstants.secondaryAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.stackLg),

                          // Title & Description
                          const Text(
                            AppStrings.noInternetTitle,
                            style: TextStyle(
                              fontFamily: AppFonts.heading,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppConstants.stackSm),
                          const Text(
                            AppStrings.noInternetMessage,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 14,
                              height: 1.4,
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
                              _buildDiagnosticChip(Icons.wifi_off_rounded, 'Wi-Fi Unreachable'),
                              _buildDiagnosticChip(Icons.signal_cellular_off_rounded, 'Cellular Disconnected'),
                              _buildDiagnosticChip(Icons.sync_problem_rounded, 'Sync Paused'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.stackLg),

                    // Action Buttons
                    AppButton(
                      text: AppStrings.btnTryAgain,
                      icon: Icons.refresh,
                      variant: AppButtonVariant.primary,
                      onPressed: onRetry,
                    ),
                    const SizedBox(height: AppConstants.stackSm),
                    AppButton(
                      text: AppStrings.btnCheckSettings,
                      icon: Icons.settings,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        PermissionService().openAppSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppConstants.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.secondaryAccent.withValues(alpha: 0.2),
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
