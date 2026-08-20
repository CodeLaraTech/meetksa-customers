import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum AppButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == AppButtonVariant.primary) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor,
          borderRadius: BorderRadius.circular(8.0),
          border: const Border(
            top: BorderSide(
              color: Color(0x4D009CA3), // 30% accent glow top border
              width: 1.5,
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D234997),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(8.0),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.secondaryAccent),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18.0, color: AppConstants.onSurface),
                          const SizedBox(width: 8.0),
                        ],
                        Text(
                          text.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: AppFonts.heading,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppConstants.onSurface,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    }

    if (variant == AppButtonVariant.secondary) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: AppConstants.secondaryAccent.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(8.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18.0, color: AppConstants.secondaryAccent),
                    const SizedBox(width: 8.0),
                  ],
                  Text(
                    text.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AppFonts.heading,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppConstants.secondaryAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 14.0,
          color: AppConstants.onSurfaceVariant,
        ),
      ),
    );
  }
}
