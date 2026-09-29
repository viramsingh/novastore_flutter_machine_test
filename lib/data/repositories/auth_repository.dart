import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService secureStorage;

  AuthRepository({
    required this.apiClient,
    required this.secureStorage,
  });

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.login,
        data: {
          'username': username.trim(),
          'password': password.trim(),
          'expiresInMins': 120,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data);
      final token = data['accessToken'] ?? data['token'] ?? '';

      if (token.isNotEmpty) {
        apiClient.setAuthToken(token);
        await secureStorage.saveSession(token: token, user: user);
      }

      return user;
    } catch (e) {
      throw apiClient.handleError(e);
    }
  }

  Future<UserModel?> restoreSession() async {
    try {
      final token = await secureStorage.getToken();
      final user = await secureStorage.getUser();

      if (token != null && token.isNotEmpty && user != null) {
        apiClient.setAuthToken(token);
        return user;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    apiClient.clearAuthToken();
    await secureStorage.clearSession();
  }
}
