import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_strings.dart';
import '../services/connectivity_service.dart';

class ConnectionBanner extends StatelessWidget {
  final ConnectionStatus status;

  const ConnectionBanner({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOffline = status == ConnectionStatus.offline;

    return AnimatedSwitcher(
      duration: AppConstants.animDurationFast,
      child: isOffline
          ? Container(
              key: const ValueKey('offline_banner'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              decoration: const BoxDecoration(
                color: Color(0xD9122131), // Glassmorphism backdrop
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFFFB4AB),
                    width: 1.0,
                  ),
                ),
              ),
              child: const SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 16,
                      color: Color(0xFFFFB4AB),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      AppStrings.offlineBannerMessage,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFFB4AB),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('online_banner')),
    );
  }
}
