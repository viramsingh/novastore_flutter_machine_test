import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/product_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiClient: client, secureStorage: storage);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProductRepository(apiClient: client);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});
