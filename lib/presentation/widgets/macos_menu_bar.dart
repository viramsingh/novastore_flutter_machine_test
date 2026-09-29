import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class MacOSMenuBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const MacOSMenuBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(28);

  @override
  ConsumerState<MacOSMenuBar> createState() => _MacOSMenuBarState();
}

class _MacOSMenuBarState extends ConsumerState<MacOSMenuBar> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][time.weekday - 1];
    return '$weekday $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    return SafeArea(
      bottom: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0x991E293B) : const Color(0xB3FFFFFF),
            border: Border(
              bottom: BorderSide(
                color: isDark ? const Color(0x33FFFFFF) : const Color(0x26000000),
                width: 0.8,
              ),
            ),
          ),
          child: Row(
            children: [
              // Apple Icon
              const Icon(Icons.apple, size: 16),
              const SizedBox(width: 14),

              // App Name & Menus
              const Text(
                'NovaStore',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              _buildMenuText('File'),
              _buildMenuText('Edit'),
              _buildMenuText('View'),
              _buildMenuText('Window'),
              _buildMenuText('Help'),

              const Spacer(),

              // Right status items: Battery, WiFi, Theme Toggle, Time, User
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 14,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
              const SizedBox(width: 10),
              const Icon(Icons.wifi, size: 14),
              const SizedBox(width: 10),
              const Icon(Icons.battery_charging_full_rounded, size: 15),
              const SizedBox(width: 12),
              Text(
                _formatTime(_now),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
              if (user != null) ...[
                const SizedBox(width: 10),
                Text(
                  user.username,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }
}
