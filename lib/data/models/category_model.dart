import 'package:flutter/material.dart';

class CategoryModel {
  final String slug;
  final String name;

  CategoryModel({
    required this.slug,
    required this.name,
  });

  factory CategoryModel.fromString(String slug) {
    // Format slug like "home-decoration" -> "Home Decoration"
    final formatted = slug
        .split('-')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
    return CategoryModel(slug: slug, name: formatted);
  }

  factory CategoryModel.fromJson(dynamic json) {
    if (json is String) {
      return CategoryModel.fromString(json);
    } else if (json is Map) {
      final slug = json['slug']?.toString() ?? json['name']?.toString() ?? '';
      final name = json['name']?.toString() ?? slug;
      return CategoryModel(slug: slug, name: name);
    }
    return CategoryModel(slug: '', name: '');
  }

  IconData get icon {
    switch (slug.toLowerCase()) {
      case 'beauty':
      case 'skin-care':
        return Icons.face_retouching_natural;
      case 'fragrances':
        return Icons.spa;
      case 'furniture':
      case 'home-decoration':
      case 'kitchen-accessories':
        return Icons.chair_outlined;
      case 'groceries':
        return Icons.local_grocery_store_outlined;
      case 'laptops':
      case 'tablets':
        return Icons.laptop_mac_outlined;
      case 'smartphones':
      case 'mobile-accessories':
        return Icons.phone_iphone;
      case 'mens-shirts':
      case 'mens-shoes':
      case 'mens-watches':
        return Icons.male;
      case 'womens-dresses':
      case 'womens-shoes':
      case 'womens-watches':
      case 'womens-bags':
      case 'womens-jewellery':
        return Icons.female;
      case 'motorcycle':
      case 'vehicle':
        return Icons.directions_car_outlined;
      case 'sports-accessories':
        return Icons.sports_tennis;
      case 'sunglasses':
        return Icons.visibility;
      default:
        return Icons.category_outlined;
    }
  }
}
