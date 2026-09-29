import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/category_model.dart';

class SliverCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<CategoryModel> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const SliverCategoryHeaderDelegate({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  double get minExtent => 54.0;

  @override
  double get maxExtent => 64.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate progress between 0.0 (fully expanded) and 1.0 (fully shrunk)
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Color interpolation using shrinkOffset as required by Task 1
    final bgColor = isDark
        ? Color.lerp(AppColors.darkSurface.withOpacity(0.85), AppColors.darkCard.withOpacity(0.98), progress)!
        : Color.lerp(Colors.white.withOpacity(0.85), Colors.white.withOpacity(0.98), progress)!;

    final elevation = lerpDouble(1.0, 6.0, progress)!;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10 + (progress * 5),
          sigmaY: 10 + (progress * 5),
        ),
        child: Container(
          height: maxExtent - shrinkOffset,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04 * elevation),
                blurRadius: elevation * 2,
                offset: Offset(0, elevation),
              ),
            ],
          ),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // "All Categories" chip
                _buildChip(
                  label: 'All Items',
                  icon: Icons.grid_view_rounded,
                  isSelected: selectedCategory == null,
                  onTap: () => onCategorySelected(null),
                  isDark: isDark,
                  progress: progress,
                ),
                const SizedBox(width: 8),

                // Individual Category chips
                ...categories.map((cat) {
                  final isSelected = selectedCategory == cat.slug;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildChip(
                      label: cat.name,
                      icon: cat.icon,
                      isSelected: isSelected,
                      onTap: () => onCategorySelected(cat.slug),
                      isDark: isDark,
                      progress: progress,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required double progress,
  }) {
    // Dynamic height and padding based on shrinkOffset progress
    final verticalPadding = lerpDouble(8.0, 5.0, progress)!;
    final fontSize = lerpDouble(13.0, 12.0, progress)!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: verticalPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverCategoryHeaderDelegate oldDelegate) {
    return oldDelegate.selectedCategory != selectedCategory ||
        oldDelegate.categories != categories;
  }
}
