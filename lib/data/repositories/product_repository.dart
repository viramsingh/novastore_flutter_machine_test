import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/local_database.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductsResult {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  ProductsResult({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });
}

class ProductRepository {
  final ApiClient apiClient;

  ProductRepository({required this.apiClient});

  Future<ProductsResult> getProducts({int limit = 20, int skip = 0}) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.products,
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final rawList = data['products'] as List? ?? [];
      final products = rawList.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList();
      final total = data['total'] as int? ?? products.length;

      // Cache first page for offline access
      if (skip == 0 && products.isNotEmpty) {
        LocalDatabase.cacheProducts(products);
      }

      return ProductsResult(
        products: products,
        total: total,
        skip: skip,
        limit: limit,
      );
    } catch (e) {
      // Offline fallback for initial page
      if (skip == 0) {
        final cached = await LocalDatabase.getCachedProducts();
        if (cached.isNotEmpty) {
          return ProductsResult(
            products: cached,
            total: cached.length,
            skip: 0,
            limit: limit,
          );
        }
      }
      throw apiClient.handleError(e);
    }
  }

  Future<ProductsResult> searchProducts({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.searchProducts,
        queryParameters: {
          'q': query,
          'limit': limit,
          'skip': skip,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final rawList = data['products'] as List? ?? [];
      final products = rawList.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList();
      final total = data['total'] as int? ?? products.length;

      return ProductsResult(
        products: products,
        total: total,
        skip: skip,
        limit: limit,
      );
    } catch (e) {
      throw apiClient.handleError(e);
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.categories);
      final rawList = response.data as List? ?? [];
      return rawList.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      throw apiClient.handleError(e);
    }
  }

  Future<ProductsResult> getProductsByCategory({
    required String category,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiConstants.productsByCategory}/$category',
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final rawList = data['products'] as List? ?? [];
      final products = rawList.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList();
      final total = data['total'] as int? ?? products.length;

      return ProductsResult(
        products: products,
        total: total,
        skip: skip,
        limit: limit,
      );
    } catch (e) {
      throw apiClient.handleError(e);
    }
  }

  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.products}/$id');
      return ProductModel.fromJson(Map<String, dynamic>.from(response.data));
    } catch (e) {
      throw apiClient.handleError(e);
    }
  }
}
