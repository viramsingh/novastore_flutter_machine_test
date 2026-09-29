import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import 'auth_provider.dart';
import 'core_providers.dart';

class CartState {
  final List<CartItemModel> items;
  final bool isLoading;
  final int? currentUserId;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.currentUserId,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get totalDiscountedPrice => items.fold(0.0, (sum, item) => sum + item.totalDiscountedPrice);
  double get totalSavings => items.fold(0.0, (sum, item) => sum + item.totalSavings);

  bool isInCart(int productId) => items.any((item) => item.product.id == productId);

  int getQuantity(int productId) {
    final item = items.cast<CartItemModel?>().firstWhere(
          (element) => element?.product.id == productId,
          orElse: () => null,
        );
    return item?.quantity ?? 0;
  }

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    int? currentUserId,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() {
    // Automatically observe auth state so cart switches when user logs in / out
    final auth = ref.watch(authProvider);
    final user = auth.user;

    if (user != null) {
      // Async load for the authenticated user
      Future.microtask(() => loadCartForUser(user.id));
      return CartState(currentUserId: user.id);
    } else {
      return const CartState();
    }
  }

  Future<void> loadCartForUser(int userId) async {
    state = state.copyWith(isLoading: true, currentUserId: userId);
    try {
      final repository = ref.read(cartRepositoryProvider);
      final loaded = await repository.loadCart(userId);
      state = state.copyWith(items: loaded, isLoading: false, currentUserId: userId);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final userId = state.currentUserId;
    if (userId == null) return;

    final existingIndex = state.items.indexWhere((item) => item.product.id == product.id);
    List<CartItemModel> updatedList = List.from(state.items);

    if (existingIndex >= 0) {
      final existingItem = updatedList[existingIndex];
      final newQty = existingItem.quantity + quantity;
      updatedList[existingIndex] = existingItem.copyWith(quantity: newQty);
    } else {
      updatedList.add(CartItemModel(
        product: product,
        quantity: quantity,
        userId: userId,
      ));
    }

    state = state.copyWith(items: updatedList);
    await ref.read(cartRepositoryProvider).saveCart(userId, updatedList);
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final userId = state.currentUserId;
    if (userId == null) return;

    List<CartItemModel> updatedList = List.from(state.items);
    if (quantity <= 0) {
      updatedList.removeWhere((item) => item.product.id == productId);
    } else {
      final index = updatedList.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        updatedList[index] = updatedList[index].copyWith(quantity: quantity);
      }
    }

    state = state.copyWith(items: updatedList);
    await ref.read(cartRepositoryProvider).saveCart(userId, updatedList);
  }

  Future<void> removeFromCart(int productId) async {
    final userId = state.currentUserId;
    if (userId == null) return;

    final updatedList = state.items.where((item) => item.product.id != productId).toList();
    state = state.copyWith(items: updatedList);
    await ref.read(cartRepositoryProvider).saveCart(userId, updatedList);
  }

  Future<void> clearCart() async {
    final userId = state.currentUserId;
    if (userId == null) return;

    state = state.copyWith(items: []);
    await ref.read(cartRepositoryProvider).clearCart(userId);
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
