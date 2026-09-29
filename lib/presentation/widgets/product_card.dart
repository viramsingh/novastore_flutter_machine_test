import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_provider.dart';
import '../screens/details/product_detail_screen.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inCart = ref.watch(cartProvider).isInCart(product.id);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image with Hero tag, discount badge, and rating
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    color: isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9),
                    child: Hero(
                      tag: 'product_img_${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.thumbnail,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),

                // Discount Pill
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${product.discountPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Rating Pill
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category / Brand
                  Text(
                    product.brand ?? product.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Title
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price and Add to Cart Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Prices
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${product.discountedPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                          ),
                          if (product.hasDiscount)
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                        ],
                      ),

                      // Quick Add Button
                      Material(
                        color: inCart ? AppColors.secondary : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            ref.read(cartProvider.notifier).addToCart(product, quantity: 1);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added "${product.title}" to cart!'),
                                duration: const Duration(seconds: 1),
                                action: SnackBarAction(
                                  label: 'VIEW',
                                  textColor: Colors.amber,
                                  onPressed: () {
                                    // Switch dock to Cart (tab index 3)
                                    // Or push cart
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            child: Icon(
                              inCart ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
