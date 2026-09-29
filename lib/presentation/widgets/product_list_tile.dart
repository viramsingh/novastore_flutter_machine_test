import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../providers/cart_provider.dart';
import '../screens/details/product_detail_screen.dart';

class ProductListTile extends ConsumerWidget {
  final ProductModel product;
  final int index;

  const ProductListTile({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inCart = ref.watch(cartProvider).isInCart(product.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(
                  product: product,
                  heroTagPrefix: 'list_${product.id}_$index',
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Left Image with rounded border
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9),
                    child: Hero(
                      tag: 'list_${product.id}_$index',
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
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Middle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            (product.brand ?? product.category).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: product.inStock
                                  ? AppColors.success.withOpacity(0.12)
                                  : AppColors.error.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.inStock ? '${product.stock} in stock' : 'Out of stock',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: product.inStock ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Right Price and Add Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    const SizedBox(height: 6),
                    Material(
                      color: inCart ? AppColors.secondary : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          ref.read(cartProvider.notifier).addToCart(product, quantity: 1);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added "${product.title}" to cart!'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                inCart ? Icons.check : Icons.add,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                inCart ? 'Added' : 'Add',
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
