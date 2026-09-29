import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import 'core_providers.dart';

class ProductsState {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const ProductsState({
    this.products = const [],
    this.total = 0,
    this.skip = 0,
    this.limit = 20,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  bool get isEmpty => !isLoading && products.isEmpty && errorMessage == null;

  ProductsState copyWith({
    List<ProductModel>? products,
    int? total,
    int? skip,
    int? limit,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductsState(
      products: products ?? this.products,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class ProductsNotifier extends Notifier<ProductsState> {
  @override
  ProductsState build() {
    Future.microtask(() => fetchInitialProducts());
    return const ProductsState(isLoading: true);
  }

  Future<void> fetchInitialProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null, skip: 0);
    try {
      final repository = ref.read(productRepositoryProvider);
      ProductsResult result;

      if (state.searchQuery.isNotEmpty) {
        result = await repository.searchProducts(
          query: state.searchQuery,
          limit: state.limit,
          skip: 0,
        );
      } else if (state.selectedCategory != null) {
        result = await repository.getProductsByCategory(
          category: state.selectedCategory!,
          limit: state.limit,
          skip: 0,
        );
      } else {
        result = await repository.getProducts(limit: state.limit, skip: 0);
      }

      state = state.copyWith(
        products: result.products,
        total: result.total,
        skip: result.products.length,
        isLoading: false,
        hasMore: result.products.length < result.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> fetchMoreProducts() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final repository = ref.read(productRepositoryProvider);
      ProductsResult result;

      if (state.searchQuery.isNotEmpty) {
        result = await repository.searchProducts(
          query: state.searchQuery,
          limit: state.limit,
          skip: state.skip,
        );
      } else if (state.selectedCategory != null) {
        result = await repository.getProductsByCategory(
          category: state.selectedCategory!,
          limit: state.limit,
          skip: state.skip,
        );
      } else {
        result = await repository.getProducts(limit: state.limit, skip: state.skip);
      }

      final combined = [...state.products, ...result.products];
      state = state.copyWith(
        products: combined,
        skip: combined.length,
        total: result.total,
        isLoadingMore: false,
        hasMore: combined.length < result.total,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> selectCategory(String? category) async {
    if (state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true, searchQuery: '');
    } else {
      state = state.copyWith(selectedCategory: category, searchQuery: '');
    }
    await fetchInitialProducts();
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, clearCategory: true);
    await fetchInitialProducts();
  }

  Future<void> refresh() async {
    await fetchInitialProducts();
  }
}

final productsProvider = NotifierProvider<ProductsNotifier, ProductsState>(ProductsNotifier.new);

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return await repository.getCategories();
});
