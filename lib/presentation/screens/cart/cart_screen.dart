import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/dock_navigation_provider.dart';
import '../details/product_detail_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 22),
            const SizedBox(width: 8),
            const Text('My Shopping Bag'),
            if (cartState.totalItemCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${cartState.totalItemCount} items',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
              tooltip: 'Clear Cart',
              onPressed: () {
                _showClearCartDialog(context, ref);
              },
            ),
        ],
      ),
      body: cartState.items.isEmpty
          ? _buildEmptyState(context, ref, isDark)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: cartState.items.length + 1, // +1 for summary card
                    itemBuilder: (context, index) {
                      if (index == cartState.items.length) {
                        return _buildOrderSummary(context, cartState, isDark);
                      }

                      final cartItem = cartState.items[index];
                      final product = cartItem.product;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  color: isDark
                                      ? const Color(0xFF131B2E)
                                      : const Color(0xFFF1F5F9),
                                  child: CachedNetworkImage(
                                    imageUrl: product.thumbnail,
                                    fit: BoxFit.contain,
                                    errorWidget: (context, url, error) => const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '\$${product.discountedPrice.toStringAsFixed(2)} each',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // Total item price
                                  Text(
                                    'Subtotal: \$${cartItem.totalDiscountedPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Adjuster (+/-)
                            Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF131B2E)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      cartItem.quantity == 1
                                          ? Icons.delete_outline
                                          : Icons.remove,
                                      size: 16,
                                      color: cartItem.quantity == 1
                                          ? AppColors.error
                                          : null,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).updateQuantity(
                                            product.id,
                                            cartItem.quantity - 1,
                                          );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      '${cartItem.quantity}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(6),
                                    onPressed: () {
                                      ref.read(cartProvider.notifier).updateQuantity(
                                            product.id,
                                            cartItem.quantity + 1,
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Checkout Bottom Sheet
                _buildCheckoutBar(context, ref, cartState, isDark),
              ],
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your Bag is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore products and add your favorite items to see them here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate back to Home tab (index 0) in the macOS Dock
                ref.read(dockNavigationProvider.notifier).selectTab(0);
              },
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: const Text('Start Shopping'),
            ),
            const SizedBox(height: 110), // Padding for dock
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartState cartState, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _summaryRow('Subtotal', '\$${cartState.totalPrice.toStringAsFixed(2)}', isDark),
          if (cartState.totalSavings > 0)
            _summaryRow(
              'Discounts Savings',
              '-\$${cartState.totalSavings.toStringAsFixed(2)}',
              isDark,
              textColor: AppColors.success,
            ),
          _summaryRow('Estimated Shipping', 'FREE', isDark, textColor: AppColors.success),
          const Divider(height: 20),
          _summaryRow(
            'Total',
            '\$${cartState.totalDiscountedPrice.toStringAsFixed(2)}',
            isDark,
            isBold: true,
            fontSize: 17,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    bool isDark, {
    Color? textColor,
    bool isBold = false,
    double fontSize = 13,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: textColor ??
                  (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 110), // Bottom padding for macOS Dock!
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '\$${cartState.totalDiscountedPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                _showCheckoutSuccessDialog(context, ref, cartState);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartProvider.notifier).clearCart();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutSuccessDialog(
    BuildContext context,
    WidgetRef ref,
    CartState cartState,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 54),
            SizedBox(height: 12),
            Text('Order Confirmed!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Your order for ${cartState.totalItemCount} items (\$${cartState.totalDiscountedPrice.toStringAsFixed(2)}) has been placed successfully!',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(cartProvider.notifier).clearCart();
                ref.read(dockNavigationProvider.notifier).selectTab(0);
              },
              child: const Text('Continue Shopping'),
            ),
          ),
        ],
      ),
    );
  }
}
