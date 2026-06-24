import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'glassmorphic_container.dart';

/// A premium shimmer loading skeleton for TicketCards.
///
/// Uses the glassmorphic container as a base and animates a
/// subtle gradient sweep to indicate loading state.
class ShimmerTicketCard extends StatelessWidget {
  const ShimmerTicketCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceVariant,
      highlightColor: AppColors.glassBorder,
      period: const Duration(milliseconds: 1500),
      child: GlassmorphicContainer(
        margin: const EdgeInsets.only(bottom: AppSizes.spacing16),
        padding: const EdgeInsets.all(AppSizes.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (ID and Date)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmerBlock(width: 80, height: 14),
                _buildShimmerBlock(width: 60, height: 14),
              ],
            ),
            const SizedBox(height: AppSizes.spacing16),

            // Title (2 lines)
            _buildShimmerBlock(width: double.infinity, height: 18),
            const SizedBox(height: AppSizes.spacing8),
            _buildShimmerBlock(width: 200, height: 18),
            
            const SizedBox(height: AppSizes.spacing24),

            // Footer (Badges)
            Row(
              children: [
                _buildShimmerBlock(width: 64, height: 24, borderRadius: AppSizes.radiusFull),
                const SizedBox(width: AppSizes.spacing8),
                _buildShimmerBlock(width: 72, height: 24, borderRadius: AppSizes.radiusFull),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerBlock({
    required double width,
    required double height,
    double borderRadius = AppSizes.radiusSmall,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
