import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';

class LocalDatabase {
  static const String cartBoxName = 'user_cart_box';
  static const String productsBoxName = 'cached_products_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(cartBoxName);
    await Hive.openBox(productsBoxName);
  }

  static Box get _cartBox => Hive.box(cartBoxName);
  static Box get _productsBox => Hive.box(productsBoxName);

  /// Saves the user's cart in Hive linked specifically to their userId
  static Future<void> saveUserCart(
    int userId,
    List<CartItemModel> items,
  ) async {
    final key = 'cart_user_$userId';
    final rawList = items.map((item) => jsonEncode(item.toJson())).toList();
    await _cartBox.put(key, rawList);
  }

  /// Retrieves the cart items for a specific user
  static Future<List<CartItemModel>> getUserCart(int userId) async {
    final key = 'cart_user_$userId';
    final rawList = _cartBox.get(key);
    if (rawList == null || rawList is! List) {
      return [];
    }

    final items = <CartItemModel>[];
    for (final item in rawList) {
      try {
        if (item is String) {
          final map = jsonDecode(item) as Map<String, dynamic>;
          items.add(CartItemModel.fromJson(map));
        } else if (item is Map) {
          items.add(CartItemModel.fromJson(Map<String, dynamic>.from(item)));
        }
      } catch (e) {
        // Skip corrupted entries safely
      }
    }
    return items;
  }

  /// Clears the user's cart
  static Future<void> clearUserCart(int userId) async {
    final key = 'cart_user_$userId';
    await _cartBox.delete(key);
  }

  /// Bonus: Offline product list caching
  static Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final rawList = products.map((p) => jsonEncode(p.toJson())).toList();
      await _productsBox.put('cached_products_list', rawList);
    } catch (_) {}
  }

  static Future<List<ProductModel>> getCachedProducts() async {
    try {
      final rawList = _productsBox.get('cached_products_list');
      if (rawList == null || rawList is! List) return [];
      final list = <ProductModel>[];
      for (final item in rawList) {
        if (item is String) {
          final map = jsonDecode(item) as Map<String, dynamic>;
          list.add(ProductModel.fromJson(map));
        }
      }
      return list;
    } catch (_) {
      return [];
    }
  }
}
