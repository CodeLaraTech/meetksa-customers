import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/permission_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/permission_card.dart';
import '../../logic/permission_controller.dart';

class PermissionCenterScreen extends StatefulWidget {
  const PermissionCenterScreen({super.key});

  @override
  State<PermissionCenterScreen> createState() => _PermissionCenterScreenState();
}

class _PermissionCenterScreenState extends State<PermissionCenterScreen> {
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppConstants.primaryColor, size: 22),
            SizedBox(width: 8),
            Text(
              AppStrings.permissionCenterTitle,
              style: TextStyle(
                fontFamily: AppFonts.heading,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppConstants.primaryColor),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppConstants.safeMargin),
            children: [
              // Security Info Card with Icons
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: AppConstants.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.permissionCenterSubtitle,
                            style: TextStyle(
                              fontFamily: AppFonts.heading,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            AppStrings.permissionCenterActiveSummary,
                            style: TextStyle(
                              fontFamily: AppFonts.body,
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.stackLg),

              // Allow All Permissions Button
              AppButton(
                text: 'Allow All Permissions',
                icon: Icons.checklist_rtl_rounded,
                variant: AppButtonVariant.primary,
                onPressed: () => _controller.requestAllPermissions(),
              ),
              const SizedBox(height: AppConstants.stackMd),

              // Permission Items
              ...AppPermissionType.values.map((type) {
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
            ],
          );
        },
      ),
    );
  }
}
