import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

/// Loading skeleton for the home screen
/// Shows placeholder content while dashboard data is being loaded
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome card skeleton
          _buildSkeletonCard(height: 120),
          const SizedBox(height: 16),

          // Quick actions skeleton
          Row(
            children: [
              Expanded(child: _buildSkeletonCard(height: 60)),
              const SizedBox(width: 12),
              Expanded(child: _buildSkeletonCard(height: 60)),
              const SizedBox(width: 12),
              Expanded(child: _buildSkeletonCard(height: 60)),
            ],
          ),
          const SizedBox(height: 24),

          // Section title skeleton
          _buildSkeletonLine(width: 200, height: 24),
          const SizedBox(height: 16),

          // Subject cards skeleton
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSkeletonCard(height: 140),
            ),
          ),

          const SizedBox(height: 24),

          // Recent activity title skeleton
          _buildSkeletonLine(width: 180, height: 24),
          const SizedBox(height: 16),

          // Recent activity items skeleton
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSkeletonCard(height: 80),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a skeleton card container
  Widget _buildSkeletonCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.lightGray.withValues(alpha: 0.3),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.lightGray.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: const Alignment(-1.0, 0.0),
                  end: const Alignment(1.0, 0.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonLine(width: double.infinity, height: 16),
                const SizedBox(height: 8),
                _buildSkeletonLine(width: 150, height: 12),
                if (height > 80) ...[
                  const SizedBox(height: 16),
                  _buildSkeletonLine(width: 100, height: 8),
                  const SizedBox(height: 8),
                  _buildSkeletonLine(width: double.infinity, height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a skeleton line
  Widget _buildSkeletonLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: AppColors.lightGray.withValues(alpha: 0.4),
      ),
    );
  }
}
