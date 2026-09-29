import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Log out',
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 110), // Padding for dock!
        child: Column(
          children: [
            // User Avatar & Name Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    backgroundImage: user?.image != null && user!.image!.isNotEmpty
                        ? CachedNetworkImageProvider(user.image!)
                        : null,
                    child: user?.image == null
                        ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName.isNotEmpty == true
                              ? user!.fullName
                              : (user?.username ?? 'Guest User'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '@${user?.username ?? "username"}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Quick Stats Row
            Row(
              children: [
                _buildStatCard(
                  'Cart Items',
                  '${cartState.totalItemCount}',
                  Icons.shopping_bag_outlined,
                  AppColors.primary,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Wishlist',
                  '12',
                  Icons.favorite_outline_rounded,
                  AppColors.secondary,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Orders',
                  '5',
                  Icons.receipt_long_outlined,
                  AppColors.accent,
                  isDark,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Settings & Features
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: Column(
                children: [
                  // Dark Mode Switch
                  ListTile(
                    leading: const Icon(Icons.brightness_6_rounded, color: AppColors.primary),
                    title: const Text('Dark Mode'),
                    subtitle: Text(isDark ? 'Dark theme active' : 'Light theme active'),
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // Secure Storage Info
                  const ListTile(
                    leading: Icon(Icons.security_rounded, color: AppColors.success),
                    title: Text('Session Security'),
                    subtitle: Text('Protected with flutter_secure_storage'),
                    trailing: Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  ),
                  const Divider(height: 1),

                  // Local DB Isolation Info
                  ListTile(
                    leading: const Icon(Icons.storage_rounded, color: AppColors.accent),
                    title: const Text('Local Database'),
                    subtitle: Text('Hive Cart linked to User ID: ${user?.id ?? "None"}'),
                    trailing: const Icon(Icons.verified, color: AppColors.accent, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Account Actions
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Saved Addresses'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.payment_outlined),
                    title: const Text('Payment Methods'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded),
                    title: const Text('Help & Customer Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                    title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.error),
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out from this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
