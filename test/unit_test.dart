import 'package:flutter_test/flutter_test.dart';
import 'package:machine_round_test/data/models/category_model.dart';
import 'package:machine_round_test/data/models/product_model.dart';
import 'package:machine_round_test/data/models/cart_item_model.dart';
import 'package:machine_round_test/data/models/user_model.dart';

void main() {
  group('ProductModel Tests', () {
    test('Calculates discounted price correctly', () {
      final product = ProductModel(
        id: 1,
        title: 'MacBook Pro',
        description: 'M3 Pro chip',
        category: 'laptops',
        price: 2000.0,
        discountPercentage: 10.0,
        rating: 4.9,
        stock: 15,
        thumbnail: 'https://example.com/thumb.png',
        images: ['https://example.com/thumb.png'],
      );

      expect(product.hasDiscount, isTrue);
      expect(product.discountedPrice, 1800.0);
      expect(product.inStock, isTrue);
    });

    test('Serializes to and from JSON', () {
      final json = {
        'id': 101,
        'title': 'Test Phone',
        'description': 'Flagship phone',
        'category': 'smartphones',
        'price': 999.99,
        'discountPercentage': 15.0,
        'rating': 4.5,
        'stock': 25,
        'thumbnail': 'https://example.com/phone.png',
        'images': ['https://example.com/phone1.png', 'https://example.com/phone2.png'],
      };

      final product = ProductModel.fromJson(json);
      expect(product.id, 101);
      expect(product.title, 'Test Phone');
      expect(product.images.length, 2);

      final encoded = product.toJson();
      expect(encoded['id'], 101);
      expect(encoded['title'], 'Test Phone');
    });
  });

  group('CartItemModel Tests', () {
    test('Computes totals, discounted totals, and savings properly', () {
      final product = ProductModel(
        id: 1,
        title: 'Wireless Headphones',
        description: 'Active Noise Cancelling',
        category: 'audio',
        price: 100.0,
        discountPercentage: 20.0, // $80 discounted price
        rating: 4.7,
        stock: 50,
        thumbnail: 'https://example.com/headphones.png',
        images: [],
      );

      final cartItem = CartItemModel(
        product: product,
        quantity: 3,
        userId: 1,
      );

      expect(cartItem.totalPrice, 300.0);
      expect(cartItem.totalDiscountedPrice, 240.0);
      expect(cartItem.totalSavings, 60.0);
    });
  });

  group('CategoryModel Tests', () {
    test('Formats kebab-case slug into readable title', () {
      final cat = CategoryModel.fromString('kitchen-accessories');
      expect(cat.name, 'Kitchen Accessories');
    });
  });

  group('UserModel Tests', () {
    test('Constructs full name and serializes properly', () {
      final user = UserModel(
        id: 1,
        username: 'emilys',
        email: 'emily@example.com',
        firstName: 'Emily',
        lastName: 'Johnson',
        accessToken: 'mock_jwt_token',
      );

      expect(user.fullName, 'Emily Johnson');
      final map = user.toJson();
      expect(map['username'], 'emilys');
      expect(map['accessToken'], 'mock_jwt_token');
    });
  });
}
