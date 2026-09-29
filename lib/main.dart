import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/storage/local_database.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_shell_screen.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDatabase.init();

  runApp(
    const ProviderScope(
      child: NovaStoreApp(),
    ),
  );
}

class NovaStoreApp extends ConsumerWidget {
  const NovaStoreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'NovaStore',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: authState.status == AuthStatus.initial
          ? const SplashScreen()
          : authState.isAuthenticated
              ? const MainShellScreen()
              : const LoginScreen(),
    );
  }
}
