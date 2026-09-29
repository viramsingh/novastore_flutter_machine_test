import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/dock_navigation_provider.dart';
import '../widgets/macos_dock.dart';
import '../widgets/macos_menu_bar.dart';
import 'cart/cart_screen.dart';
import 'categories/categories_screen.dart';
import 'home/home_screen.dart';
import 'placeholder_screen.dart';
import 'profile/profile_screen.dart';
import 'search/search_screen.dart';

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navState = ref.watch(dockNavigationProvider);

    Widget currentScreen;
    switch (navState.selectedIndex) {
      case 0:
        currentScreen = const HomeScreen();
        break;
      case 1:
        currentScreen = const SearchScreen();
        break;
      case 2:
        currentScreen = const CategoriesScreen();
        break;
      case 3:
        currentScreen = const CartScreen();
        break;
      case 4:
        currentScreen = const PlaceholderScreen(
          title: 'My Wishlist',
          icon: Icons.favorite_rounded,
          description: 'Your saved favorite items and collections.',
        );
        break;
      case 5:
        currentScreen = const PlaceholderScreen(
          title: 'My Orders',
          icon: Icons.receipt_long_rounded,
          description: 'Track, view, or manage your past and active orders.',
        );
        break;
      case 6:
        currentScreen = const PlaceholderScreen(
          title: 'Hot Flash Deals',
          icon: Icons.local_fire_department_rounded,
          description: 'Limited time daily deals with up to 70% discounts.',
        );
        break;
      case 7:
        currentScreen = const PlaceholderScreen(
          title: 'Support & Chat',
          icon: Icons.chat_bubble_rounded,
          description: 'Live 24/7 customer service assistance and order messages.',
        );
        break;
      case 8:
        currentScreen = const PlaceholderScreen(
          title: 'Notifications',
          icon: Icons.notifications_rounded,
          description: 'Stay updated on flash sales, shipping updates, and price drops.',
        );
        break;
      case 9:
        currentScreen = const ProfileScreen();
        break;
      case 10:
        currentScreen = const PlaceholderScreen(
          title: 'Nova Wallet',
          icon: Icons.account_balance_wallet_rounded,
          description: 'Manage your payment cards, balance, and reward points.',
        );
        break;
      case 11:
        currentScreen = const PlaceholderScreen(
          title: 'Coupons & Promos',
          icon: Icons.confirmation_number_rounded,
          description: 'Exclusive discount vouchers ready to be applied on checkout.',
        );
        break;
      case 12:
        currentScreen = const PlaceholderScreen(
          title: 'Product Reviews',
          icon: Icons.star_rounded,
          description: 'Read and write honest verified buyer reviews.',
        );
        break;
      case 13:
        currentScreen = const PlaceholderScreen(
          title: 'Browsing History',
          icon: Icons.history_rounded,
          description: 'Quickly find items you recently explored.',
        );
        break;
      case 14:
        currentScreen = const PlaceholderScreen(
          title: 'Delivery Tracking',
          icon: Icons.local_shipping_rounded,
          description: 'Live GPS package transit and shipment status updates.',
        );
        break;
      case 15:
        currentScreen = const PlaceholderScreen(
          title: 'QR & Barcode Scanner',
          icon: Icons.qr_code_scanner_rounded,
          description: 'Scan physical barcodes in retail stores for instant online discounts.',
        );
        break;
      case 16:
        currentScreen = const PlaceholderScreen(
          title: 'Tax Invoices & Receipts',
          icon: Icons.download_rounded,
          description: 'Download PDF invoices for all your past purchases.',
        );
        break;
      case 18:
        currentScreen = const ProfileScreen();
        break;
      default:
        currentScreen = const HomeScreen();
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const MacOSMenuBar(),
      body: Stack(
        children: [
          // Active Screen with IndexedStack or AnimatedSwitcher for smooth transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: KeyedSubtree(
              key: ValueKey(navState.selectedIndex),
              child: currentScreen,
            ),
          ),

          // Floating macOS Dock at bottom center
          const MacOSDock(),
        ],
      ),
    );
  }
}
