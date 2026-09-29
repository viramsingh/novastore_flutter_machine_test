import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/dock_navigation_provider.dart';
import '../providers/theme_provider.dart';

class DockItemData {
  final int id;
  final String label;
  final IconData icon;
  final Color baseColor;
  final Color gradientEnd;
  final bool isCart;

  const DockItemData({
    required this.id,
    required this.label,
    required this.icon,
    required this.baseColor,
    required this.gradientEnd,
    this.isCart = false,
  });
}

final List<DockItemData> dockItems = [
  const DockItemData(
    id: 0,
    label: 'Home',
    icon: Icons.home_rounded,
    baseColor: Color(0xFF3B82F6),
    gradientEnd: Color(0xFF1D4ED8),
  ),
  const DockItemData(
    id: 1,
    label: 'Search',
    icon: Icons.search_rounded,
    baseColor: Color(0xFF8B5CF6),
    gradientEnd: Color(0xFF6D28D9),
  ),
  const DockItemData(
    id: 2,
    label: 'Categories',
    icon: Icons.category_rounded,
    baseColor: Color(0xFF10B981),
    gradientEnd: Color(0xFF047857),
  ),
  const DockItemData(
    id: 3,
    label: 'Cart',
    icon: Icons.shopping_bag_rounded,
    baseColor: Color(0xFFF43F5E),
    gradientEnd: Color(0xFFBE123C),
    isCart: true,
  ),
  const DockItemData(
    id: 4,
    label: 'Wishlist',
    icon: Icons.favorite_rounded,
    baseColor: Color(0xFFEC4899),
    gradientEnd: Color(0xFFBE185D),
  ),
  const DockItemData(
    id: 5,
    label: 'Orders',
    icon: Icons.receipt_long_rounded,
    baseColor: Color(0xFFF59E0B),
    gradientEnd: Color(0xFFB45309),
  ),
  const DockItemData(
    id: 6,
    label: 'Hot Deals',
    icon: Icons.local_fire_department_rounded,
    baseColor: Color(0xFFEF4444),
    gradientEnd: Color(0xFFB91C1C),
  ),
  const DockItemData(
    id: 7,
    label: 'Messages',
    icon: Icons.chat_bubble_rounded,
    baseColor: Color(0xFF06B6D4),
    gradientEnd: Color(0xFF0E7490),
  ),
  const DockItemData(
    id: 8,
    label: 'Alerts',
    icon: Icons.notifications_rounded,
    baseColor: Color(0xFF6366F1),
    gradientEnd: Color(0xFF4338CA),
  ),
  const DockItemData(
    id: 9,
    label: 'Profile',
    icon: Icons.person_rounded,
    baseColor: Color(0xFF14B8A6),
    gradientEnd: Color(0xFF0F766E),
  ),
  const DockItemData(
    id: 10,
    label: 'Wallet',
    icon: Icons.account_balance_wallet_rounded,
    baseColor: Color(0xFF10B981),
    gradientEnd: Color(0xFF059669),
  ),
  const DockItemData(
    id: 11,
    label: 'Coupons',
    icon: Icons.confirmation_number_rounded,
    baseColor: Color(0xFFF97316),
    gradientEnd: Color(0xFFC2410C),
  ),
  const DockItemData(
    id: 12,
    label: 'Reviews',
    icon: Icons.star_rounded,
    baseColor: Color(0xFFEAB308),
    gradientEnd: Color(0xFFA16207),
  ),
  const DockItemData(
    id: 13,
    label: 'History',
    icon: Icons.history_rounded,
    baseColor: Color(0xFF64748B),
    gradientEnd: Color(0xFF334155),
  ),
  const DockItemData(
    id: 14,
    label: 'Tracking',
    icon: Icons.local_shipping_rounded,
    baseColor: Color(0xFF0284C7),
    gradientEnd: Color(0xFF0369A1),
  ),
  const DockItemData(
    id: 15,
    label: 'Scanner',
    icon: Icons.qr_code_scanner_rounded,
    baseColor: Color(0xFF84CC16),
    gradientEnd: Color(0xFF4D7C0F),
  ),
  const DockItemData(
    id: 16,
    label: 'Receipts',
    icon: Icons.download_rounded,
    baseColor: Color(0xFF0D9488),
    gradientEnd: Color(0xFF115E59),
  ),
  const DockItemData(
    id: 17,
    label: 'Theme',
    icon: Icons.brightness_6_rounded,
    baseColor: Color(0xFF8B5CF6),
    gradientEnd: Color(0xFF5B21B6),
  ),
  const DockItemData(
    id: 18,
    label: 'Settings',
    icon: Icons.settings_rounded,
    baseColor: Color(0xFF64748B),
    gradientEnd: Color(0xFF475569),
  ),
  const DockItemData(
    id: 19,
    label: 'Logout',
    icon: Icons.logout_rounded,
    baseColor: Color(0xFFEF4444),
    gradientEnd: Color(0xFF991B1B),
  ),
];

class MacOSDock extends ConsumerStatefulWidget {
  final Function(int index)? onItemSelected;

  const MacOSDock({super.key, this.onItemSelected});

  @override
  ConsumerState<MacOSDock> createState() => _MacOSDockState();
}

class _MacOSDockState extends ConsumerState<MacOSDock>
    with SingleTickerProviderStateMixin {
  double? _pointerX;
  double? _pointerDownX;
  int? _hoveredIndex;
  final ScrollController _scrollController = ScrollController();

  // Bouncing animations map for tapped icons
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  int? _currentlyBouncingIndex;

  static const double baseIconSize = 44.0;
  static const double maxIconScale = 1.65;
  static const double effectRadius = 110.0;
  static const double itemSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -20.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 20),
    ]).animate(_bounceController);

    _bounceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentlyBouncingIndex = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _triggerBounce(int index) {
    setState(() {
      _currentlyBouncingIndex = index;
    });
    _bounceController.forward(from: 0.0);
  }

  double _getScaleForItem(int index, double itemCenterX) {
    if (_pointerX == null) return 1.0;
    final distance = (_pointerX! - itemCenterX).abs();
    if (distance > effectRadius) return 1.0;

    // Smooth cosine wave falloff (classic macOS dock feel)
    final normalized = distance / effectRadius;
    final curve = math.cos(normalized * math.pi / 2.0);
    return 1.0 + (maxIconScale - 1.0) * (curve * curve);
  }

  void _handleTap(int index) {
    _triggerBounce(index);

    if (index == 17) {
      // Theme toggle shortcut
      ref.read(themeModeProvider.notifier).toggleTheme();
      return;
    }

    if (index == 19) {
      // Logout confirmation
      _showLogoutDialog();
      return;
    }

    ref.read(dockNavigationProvider.notifier).selectTab(index);
    if (widget.onItemSelected != null) {
      widget.onItemSelected!(index);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),
            SizedBox(width: 10),
            Text('Log Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out? Your cart and preferences will remain saved safely for your next session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navState = ref.watch(dockNavigationProvider);
    final cartState = ref.watch(cartProvider);

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tooltip label above hovered icon
              IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _hoveredIndex != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xE61E293B)
                          : const Color(0xE60F172A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      _hoveredIndex != null ? dockItems[_hoveredIndex!].label : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),

              // The Translucent Floating Rounded macOS Dock
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.dockGlassDark
                          : AppColors.dockGlassLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? AppColors.dockBorderDark
                            : AppColors.dockBorderLight,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.45 : 0.15),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Listener(
                      // Handles mobile touch and drag across the dock
                      onPointerDown: (event) {
                        _pointerDownX = event.localPosition.dx;
                      },
                      onPointerMove: (event) {
                        final dx = event.localPosition.dx;
                        if (_pointerDownX != null && (dx - _pointerDownX!).abs() > 8) {
                          setState(() {
                            _pointerX = dx;
                          });
                        }
                      },
                      onPointerUp: (event) {
                        final upX = event.localPosition.dx;
                        final wasTap = _pointerDownX != null && (upX - _pointerDownX!).abs() < 16;
                        _pointerDownX = null;
                        setState(() {
                          _pointerX = null;
                          _hoveredIndex = null;
                        });

                        if (wasTap) {
                          final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                          final rowX = upX - 12 + scrollOffset;
                          final itemTotalWidth = baseIconSize + itemSpacing;
                          final tappedIndex = (rowX / itemTotalWidth).floor();
                          if (tappedIndex >= 0 && tappedIndex < dockItems.length) {
                            _handleTap(tappedIndex);
                          }
                        }
                      },
                      onPointerCancel: (_) {
                        _pointerDownX = null;
                        setState(() {
                          _pointerX = null;
                          _hoveredIndex = null;
                        });
                      },
                      child: MouseRegion(
                        // Handles desktop/web hover
                        onHover: (event) {
                          setState(() {
                            _pointerX = event.localPosition.dx;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            _pointerX = null;
                            _hoveredIndex = null;
                          });
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(dockItems.length, (index) {
                              final item = dockItems[index];
                              final isSelected = navState.selectedIndex == index;

                              // Calculate center X of this item inside the row
                              final itemCenter = index * (baseIconSize + itemSpacing) + (baseIconSize / 2);
                              final scale = _getScaleForItem(index, itemCenter);

                              // Update hovered index for tooltip
                              if (_pointerX != null && (_pointerX! - itemCenter).abs() < (baseIconSize / 2 + 6)) {
                                _hoveredIndex = index;
                              }

                              final isBouncing = _currentlyBouncingIndex == index;

                              return AnimatedBuilder(
                                animation: _bounceAnimation,
                                builder: (context, child) {
                                  final bounceOffsetY = isBouncing ? _bounceAnimation.value : 0.0;

                                  return Transform.translate(
                                    offset: Offset(0, bounceOffsetY),
                                    child: child,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: itemSpacing / 2),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Magnified Icon with Touch / Click gesture
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => _handleTap(index),
                                        child: Transform.scale(
                                          scale: scale,
                                          alignment: Alignment.bottomCenter,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                width: baseIconSize,
                                                height: baseIconSize,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [item.baseColor, item.gradientEnd],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: item.baseColor.withOpacity(0.35),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  item.icon,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),

                                              // Live Cart Badge
                                              if (item.isCart && cartState.totalItemCount > 0)
                                                Positioned(
                                                  top: -4,
                                                  right: -4,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.secondary,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.5,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppColors.secondary.withOpacity(0.5),
                                                          blurRadius: 4,
                                                        ),
                                                      ],
                                                    ),
                                                    constraints: const BoxConstraints(
                                                      minWidth: 18,
                                                      minHeight: 18,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        cartState.totalItemCount > 99
                                                            ? '99+'
                                                            : '${cartState.totalItemCount}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      // macOS Active indicator dot
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? (isDark ? Colors.white : AppColors.primary)
                                              : Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
