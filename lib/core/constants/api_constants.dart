class ApiConstants {
  static const String baseUrl = 'https://dummyjson.com';

  static const String login = '/auth/login';
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/category-list';
  static const String productsByCategory = '/products/category';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
