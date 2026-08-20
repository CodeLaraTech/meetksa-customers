import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/permission_card.dart';
import '../../logic/permission_controller.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  late final PermissionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PermissionController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Glow Pattern
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.primaryColor.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Main Scrollable Content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return SafeArea(
                child: Column(
                  children: [
                    // Top App Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.safeMargin,
                        vertical: AppConstants.stackSm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.hub,
                            color: AppConstants.primaryColor.withValues(alpha: 0.9),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontFamily: AppFonts.heading,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.safeMargin,
                          vertical: AppConstants.stackMd,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            // Header Logo & Text
                            const AppLogo(size: 72.0, useGlassmorphism: false),
                            const SizedBox(height: AppConstants.stackMd),
                            const Text(
                              AppStrings.permissionSetupTitle,
                              style: TextStyle(
                                fontFamily: AppFonts.heading,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              AppStrings.permissionSetupSubtitle,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 14,
                                color: Color(0xFF475569),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.stackLg),

                            // Permission Cards List
                            ...[
                              AppPermissionType.location,
                              AppPermissionType.camera,
                              AppPermissionType.notifications,
                              AppPermissionType.photosAndFiles,
                            ].map((type) {
                              final status =
                                  _controller.permissionStatuses[type] ?? AppPermissionStatus.denied;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppConstants.stackSm),
                                child: PermissionCard(
                                  permissionType: type,
                                  status: status,
                                  onTap: () => _controller.requestPermission(type),
                                ),
                              );
                            }),

                            const SizedBox(height: 140), // Bottom padding for sticky buttons
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Bottom Fixed Action Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.safeMargin),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFF8FAFC).withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      text: 'Allow All Permissions',
                      icon: Icons.checklist_rtl_rounded,
                      variant: AppButtonVariant.primary,
                      onPressed: () => _controller.requestAllPermissions(),
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      text: AppStrings.btnContinue,
                      icon: Icons.arrow_forward,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => _controller.completeSetupAndProceed(context),
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
}
