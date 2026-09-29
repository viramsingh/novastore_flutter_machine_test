import '../../core/storage/local_database.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  Future<List<CartItemModel>> loadCart(int userId) async {
    return await LocalDatabase.getUserCart(userId);
  }

  Future<void> saveCart(int userId, List<CartItemModel> items) async {
    await LocalDatabase.saveUserCart(userId, items);
  }

  Future<void> clearCart(int userId) async {
    await LocalDatabase.clearUserCart(userId);
  }
}
