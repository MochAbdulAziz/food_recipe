import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/colors.dart';

/// Shimmer skeleton that mirrors the layout of [RecipeDetailScreen].
class SkeletonDetail extends StatelessWidget {
  const SkeletonDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Shimmer.fromColors(
        baseColor: AppColors.bgMuted,
        highlightColor: AppColors.secondary,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image
              _box(
                width: double.infinity,
                height: 320,
                radius: 0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    _box(width: 220, height: 22, radius: 8),
                    const SizedBox(height: 10),
                    // Description
                    _box(width: double.infinity, height: 13, radius: 6),
                    const SizedBox(height: 6),
                    _box(width: 200, height: 13, radius: 6),
                    const SizedBox(height: 24),
                    // Nutrition row
                    Row(
                      children: List.generate(
                        4,
                        (_) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _box(width: double.infinity, height: 56, radius: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Ingredients header
                    _box(width: 120, height: 16, radius: 6),
                    const SizedBox(height: 12),
                    ...List.generate(
                      5,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _box(width: double.infinity, height: 36, radius: 10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Steps header
                    _box(width: 100, height: 16, radius: 6),
                    const SizedBox(height: 12),
                    ...List.generate(
                      3,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _box(width: double.infinity, height: 72, radius: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
