import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../constants/permission_constants.dart';

class PermissionCard extends StatelessWidget {
  final AppPermissionType permissionType;
  final AppPermissionStatus status;
  final VoidCallback onTap;

  const PermissionCard({
    super.key,
    required this.permissionType,
    required this.status,
    required this.onTap,
  });

  IconData _getIcon() {
    switch (permissionType) {
      case AppPermissionType.location:
        return Icons.location_on_rounded;
      case AppPermissionType.camera:
        return Icons.camera_alt_rounded;
      case AppPermissionType.notifications:
        return Icons.notifications_active_rounded;
      case AppPermissionType.photosAndFiles:
        return Icons.folder_copy_rounded;
    }
  }

  Color _getIconBgColor() {
    switch (permissionType) {
      case AppPermissionType.location:
        return const Color(0xFF0EA5E9);
      case AppPermissionType.camera:
        return const Color(0xFF8B5CF6);
      case AppPermissionType.notifications:
        return const Color(0xFF10B981);
      case AppPermissionType.photosAndFiles:
        return const Color(0xFF3B82F6);
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case AppPermissionStatus.granted:
        return AppStrings.statusGranted.toUpperCase();
      case AppPermissionStatus.permanentlyDenied:
        return AppStrings.statusPermanentlyDenied.toUpperCase();
      case AppPermissionStatus.restricted:
        return AppStrings.statusRestricted.toUpperCase();
      case AppPermissionStatus.limited:
        return AppStrings.statusLimited.toUpperCase();
      case AppPermissionStatus.denied:
        return AppStrings.statusDenied.toUpperCase();
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case AppPermissionStatus.granted:
        return const Color(0xFF10B981);
      case AppPermissionStatus.permanentlyDenied:
        return const Color(0xFFEF4444);
      case AppPermissionStatus.restricted:
      case AppPermissionStatus.limited:
        return const Color(0xFFF59E0B);
      case AppPermissionStatus.denied:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case AppPermissionStatus.granted:
        return Icons.check_circle_rounded;
      case AppPermissionStatus.permanentlyDenied:
        return Icons.error_rounded;
      case AppPermissionStatus.restricted:
      case AppPermissionStatus.limited:
        return Icons.warning_rounded;
      case AppPermissionStatus.denied:
        return Icons.add_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGranted = status == AppPermissionStatus.granted;
    final statusColor = _getStatusColor();
    final iconBg = _getIconBgColor();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isGranted ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
          width: isGranted ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Colorful Icon Container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    _getIcon(),
                    color: iconBg,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        permissionType.title,
                        style: const TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        permissionType.description,
                        style: const TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Status Badge with Icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getStatusLabel(),
                        style: TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
