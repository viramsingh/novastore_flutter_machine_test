import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SliverSectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String subtitle;
  final IconData icon;
  final int count;

  const SliverSectionHeaderDelegate({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
  });

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Color interpolation using shrinkOffset
    final bgColor = isDark
        ? Color.lerp(
            AppColors.darkSurface.withOpacity(0.9),
            AppColors.darkCard.withOpacity(0.98),
            progress,
          )!
        : Color.lerp(
            AppColors.lightBackground.withOpacity(0.9),
            Colors.white.withOpacity(0.98),
            progress,
          )!;

    final titleSize = lerpDouble(17.0, 15.0, progress)!;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: maxExtent - shrinkOffset,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (progress < 0.6)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count items',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverSectionHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.count != count ||
        oldDelegate.subtitle != subtitle;
  }
}
