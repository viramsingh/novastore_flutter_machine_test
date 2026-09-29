import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/dock_navigation_provider.dart';
import '../../providers/product_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.category_outlined, size: 22),
            SizedBox(width: 8),
            Text('All Categories'),
          ],
        ),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110), // Padding for dock!
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.25,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  ref.read(productsProvider.notifier).selectCategory(cat.slug);
                  // Switch dock to Home tab (index 0)
                  ref.read(dockNavigationProvider.notifier).selectTab(0);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(cat.icon, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Failed to load categories: $err'),
            ],
          ),
        ),
      ),
    );
  }
}
