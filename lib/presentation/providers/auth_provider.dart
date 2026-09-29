import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import 'core_providers.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState(status: AuthStatus.initial);
  }

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.restoreSession();
      if (user != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(username: username, password: password);
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
