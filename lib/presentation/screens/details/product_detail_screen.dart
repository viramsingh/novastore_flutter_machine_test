import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;
  final String? heroTagPrefix;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.heroTagPrefix,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final product = widget.product;
    final heroTag = widget.heroTagPrefix ?? 'product_img_${product.id}';
    final cartState = ref.watch(cartProvider);
    final inCart = cartState.isInCart(product.id);
    final currentCartQty = cartState.getQuantity(product.id);

    final displayImages = product.images.isNotEmpty
        ? product.images
        : [product.thumbnail];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          product.category.toUpperCase(),
          style: const TextStyle(fontSize: 14, letterSpacing: 1.0, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing product link...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved to Wishlist!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image Carousel
                  Container(
                    height: 280,
                    width: double.infinity,
                    color: isDark ? const Color(0xFF131B2E) : Colors.white,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: displayImages.length,
                          onPageChanged: (index) {
                            setState(() {
                              _selectedImageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final imgUrl = displayImages[index];
                            final isFirst = index == 0;

                            final imageWidget = CachedNetworkImage(
                              imageUrl: imgUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_not_supported_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );

                            return isFirst
                                ? Hero(tag: heroTag, child: imageWidget)
                                : imageWidget;
                          },
                        ),

                        // Discount badge
                        if (product.hasDiscount)
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.error.withOpacity(0.3),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Text(
                                '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                        // Page dots indicator
                        if (displayImages.length > 1)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(displayImages.length, (index) {
                                final isSelected = _selectedImageIndex == index;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: isSelected ? 20 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Image thumbnails row
                  if (displayImages.length > 1)
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(displayImages.length, (index) {
                          final isSelected = _selectedImageIndex == index;
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: displayImages[index],
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                  // Details section
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand and Rating
                        Row(
                          children: [
                            if (product.brand != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  product.brand!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Price & Savings
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${product.discountedPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.primaryLight : AppColors.primary,
                              ),
                            ),
                            if (product.hasDiscount) ...[
                              const SizedBox(width: 10),
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  decoration: TextDecoration.lineThrough,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Save \$${(product.price - product.discountedPrice).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),

                        // In Stock status
                        Row(
                          children: [
                            Icon(
                              product.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              size: 16,
                              color: product.inStock ? AppColors.success : AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.inStock
                                  ? 'In Stock (${product.stock} available)'
                                  : 'Currently unavailable',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: product.inStock ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 32),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),

                        const Divider(height: 32),

                        // Specifications / Perks
                        const Text(
                          'Delivery & Policies',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildPerkRow(
                          icon: Icons.local_shipping_outlined,
                          title: 'Shipping',
                          subtitle: product.shippingInformation ?? 'Standard delivery 2-4 days',
                          isDark: isDark,
                        ),
                        _buildPerkRow(
                          icon: Icons.assignment_return_outlined,
                          title: 'Return Policy',
                          subtitle: product.returnPolicy ?? '30-day money-back guarantee',
                          isDark: isDark,
                        ),
                        _buildPerkRow(
                          icon: Icons.verified_user_outlined,
                          title: 'Warranty',
                          subtitle: product.warrantyInformation ?? '1-year brand warranty',
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar with Quantity Selector & Add to Cart Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Quantity selector
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131B2E) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 18),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Add to Cart Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: inCart ? AppColors.secondary : AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        ref.read(cartProvider.notifier).addToCart(product, quantity: _quantity);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added $_quantity x "${product.title}" to cart! ${currentCartQty > 0 ? "Total: ${currentCartQty + _quantity}" : ""}',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(inCart ? Icons.check_circle_rounded : Icons.shopping_bag_rounded),
                          const SizedBox(width: 8),
                          Text(
                            inCart
                                ? 'Add More (\$${(product.discountedPrice * _quantity).toStringAsFixed(2)})'
                                : 'Add to Cart • \$${(product.discountedPrice * _quantity).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerkRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
