import 'package:flutter/material.dart';

class WebViewSkeletonLoader extends StatefulWidget {
  const WebViewSkeletonLoader({super.key});

  @override
  State<WebViewSkeletonLoader> createState() => _WebViewSkeletonLoaderState();
}

class _WebViewSkeletonLoaderState extends State<WebViewSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final double shimmerVal = _shimmerController.value;

        return Container(
          color: const Color(0xFFF8FAFC),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Search Bar Skeleton
              _buildSkeletonBox(
                width: double.infinity,
                height: 44.0,
                borderRadius: 12.0,
                shimmerVal: shimmerVal,
              ),
              const SizedBox(height: 20.0),

              // Hero Banner Skeleton
              _buildSkeletonBox(
                width: double.infinity,
                height: 160.0,
                borderRadius: 16.0,
                shimmerVal: shimmerVal,
              ),
              const SizedBox(height: 24.0),

              // Category Avatars Skeleton Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Column(
                    children: [
                      _buildSkeletonBox(
                        width: 56.0,
                        height: 56.0,
                        borderRadius: 28.0,
                        shimmerVal: shimmerVal,
                      ),
                      const SizedBox(height: 8.0),
                      _buildSkeletonBox(
                        width: 44.0,
                        height: 10.0,
                        borderRadius: 4.0,
                        shimmerVal: shimmerVal,
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 28.0),

              // Content Section Title Skeleton
              _buildSkeletonBox(
                width: 140.0,
                height: 16.0,
                borderRadius: 4.0,
                shimmerVal: shimmerVal,
              ),
              const SizedBox(height: 16.0),

              // List Items Skeleton Cards
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildSkeletonBox(
                            width: 50.0,
                            height: 50.0,
                            borderRadius: 10.0,
                            shimmerVal: shimmerVal,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSkeletonBox(
                                  width: double.infinity,
                                  height: 12.0,
                                  borderRadius: 4.0,
                                  shimmerVal: shimmerVal,
                                ),
                                const SizedBox(height: 8.0),
                                _buildSkeletonBox(
                                  width: 120.0,
                                  height: 10.0,
                                  borderRadius: 4.0,
                                  shimmerVal: shimmerVal,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    required double borderRadius,
    required double shimmerVal,
  }) {
    const double baseOpacity = 0.06;
    const double highlightOpacity = 0.16;
    final double currentOpacity = baseOpacity +
        (highlightOpacity - baseOpacity) *
            (0.5 + 0.5 * (shimmerVal * 6.28318).abs().clamp(-1.0, 1.0));

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: currentOpacity),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
