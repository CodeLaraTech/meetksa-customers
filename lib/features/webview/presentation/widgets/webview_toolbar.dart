import 'package:flutter/material.dart';

import '../../../../app/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/app_logo.dart';

class WebViewToolbar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;
  final bool isConnecting;
  final ConnectionStatus connectionStatus;

  const WebViewToolbar({
    super.key,
    required this.onRefresh,
    this.isConnecting = false,
    this.connectionStatus = ConnectionStatus.online,
  });

  static const double slimHeaderHeight = 48.0;

  @override
  Size get preferredSize => const Size.fromHeight(slimHeaderHeight);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;

    final bool isOffline = connectionStatus == ConnectionStatus.offline;

    final String? statusText = isOffline
        ? AppStrings.systemOfflineBadge
        : (isConnecting ? AppStrings.systemConnectingBadge : null);

    final Color? statusColor = isOffline
        ? const Color(0xFFFF6B6B)
        : (isConnecting ? AppConstants.secondaryAccent : null);

    return Container(
      decoration: const BoxDecoration(
        color: AppConstants.primaryColor,
        border: Border(
          bottom: BorderSide(
            color: Color(0x1AFFFFFF),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: slimHeaderHeight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                // Compact Logo
                AppLogo(size: isSmallScreen ? 24.0 : 28.0, useGlassmorphism: false),
                SizedBox(width: isSmallScreen ? 8.0 : 10.0),

                // Responsive Title & Connection Status Badge
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.heading,
                          fontSize: isSmallScreen ? 14.0 : 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (statusText != null && statusColor != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                statusText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppFonts.heading,
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Refresh Button
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    tooltip: AppStrings.tooltipRefresh,
                    onPressed: onRefresh,
                  ),
                ),

                const SizedBox(width: 2),

                // 3-Dots Menu
                SizedBox(
                  width: 36,
                  height: 36,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    offset: const Offset(0, 44),
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 20),
                    color: AppConstants.surfaceContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    onSelected: (value) {
                      if (value == 'permissions') {
                        Navigator.of(context).pushNamed(AppRoutes.permissionCenter);
                      } else if (value == 'refresh') {
                        onRefresh();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return const [
                        PopupMenuItem<String>(
                          value: 'permissions',
                          child: Row(
                            children: [
                              Icon(Icons.security, size: 18, color: AppConstants.onSurface),
                              SizedBox(width: 8),
                              Text(AppStrings.permissionCenterTitle, style: TextStyle(color: AppConstants.onSurface, fontSize: 13)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'refresh',
                          child: Row(
                            children: [
                              Icon(Icons.refresh, size: 18, color: AppConstants.onSurface),
                              SizedBox(width: 8),
                              Text(AppStrings.btnReload, style: TextStyle(color: AppConstants.onSurface, fontSize: 13)),
                            ],
                          ),
                        ),
                      ];
                    },
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
