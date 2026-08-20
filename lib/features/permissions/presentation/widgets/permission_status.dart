import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/permission_constants.dart';

class PermissionStatusIndicator extends StatelessWidget {
  final AppPermissionStatus status;

  const PermissionStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isGranted = status == AppPermissionStatus.granted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isGranted
            ? AppConstants.secondaryAccent.withValues(alpha: 0.15)
            : AppConstants.outlineColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isGranted ? AppConstants.secondaryAccent : AppConstants.outlineColor,
          width: 1.0,
        ),
      ),
      child: Text(
        isGranted ? AppStrings.statusGranted.toUpperCase() : AppStrings.statusDenied.toUpperCase(),
        style: TextStyle(
          fontFamily: AppFonts.heading,
          fontSize: 10.0,
          fontWeight: FontWeight.w700,
          color: isGranted ? AppConstants.secondaryAccent : AppConstants.outlineColor,
        ),
      ),
    );
  }
}
