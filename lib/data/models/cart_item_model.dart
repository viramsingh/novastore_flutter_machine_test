import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;
  final int userId;

  CartItemModel({
    required this.product,
    required this.quantity,
    required this.userId,
  });

  double get totalPrice => product.price * quantity;
  double get totalDiscountedPrice => product.discountedPrice * quantity;
  double get totalSavings => (product.price - product.discountedPrice) * quantity;

  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    int? userId,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      userId: userId ?? this.userId,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
      quantity: json['quantity'] as int? ?? 1,
      userId: json['userId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'userId': userId,
    };
  }
}
