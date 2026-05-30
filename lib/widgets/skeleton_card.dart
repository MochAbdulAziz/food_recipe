import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/colors.dart';

/// Shimmer skeleton that mirrors the layout of [FoodCard].
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.bgMuted,
        highlightColor: AppColors.secondary,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image placeholder
            Padding(
              padding: const EdgeInsets.all(12),
              child: _box(width: 88, height: 88, radius: 14),
            ),
            // Text placeholders
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 130, height: 13, radius: 6),
                    const SizedBox(height: 8),
                    _box(width: double.infinity, height: 10, radius: 6),
                    const SizedBox(height: 4),
                    _box(width: 100, height: 10, radius: 6),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _box(width: 70, height: 10, radius: 6),
                        const Spacer(),
                        _box(width: 50, height: 10, radius: 6),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _box({required double width, required double height, required double radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A full list of skeleton cards, used as the home loading state.
class SkeletonFeedList extends StatelessWidget {
  final int count;
  const SkeletonFeedList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}
