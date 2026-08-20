import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppLoadingProgressIndicator extends StatefulWidget {
  final double width;
  final double height;

  const AppLoadingProgressIndicator({
    super.key,
    this.width = 192.0,
    this.height = 2.0,
  });

  @override
  State<AppLoadingProgressIndicator> createState() => _AppLoadingProgressIndicatorState();
}

class _AppLoadingProgressIndicatorState extends State<AppLoadingProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppConstants.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(widget.height),
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double value = _controller.value;
          return FractionalTranslation(
            translation: Offset(-1.0 + (value * 2.5), 0.0),
            child: Container(
              width: widget.width * 0.4,
              decoration: BoxDecoration(
                color: AppConstants.secondaryAccent,
                borderRadius: BorderRadius.circular(widget.height),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x99009CA3),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
