class ProductModel {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String? brand;
  final String thumbnail;
  final List<String> images;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final String? returnPolicy;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    this.brand,
    required this.thumbnail,
    required this.images,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.returnPolicy,
  });

  double get discountedPrice {
    if (discountPercentage <= 0) return price;
    return price * (1.0 - (discountPercentage / 100.0));
  }

  bool get hasDiscount => discountPercentage > 0;
  bool get inStock => stock > 0;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] is List) {
      parsedImages = (json['images'] as List)
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    final thumb = json['thumbnail']?.toString() ??
        (parsedImages.isNotEmpty ? parsedImages.first : '');

    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand']?.toString(),
      thumbnail: thumb,
      images: parsedImages.isNotEmpty ? parsedImages : (thumb.isNotEmpty ? [thumb] : []),
      warrantyInformation: json['warrantyInformation']?.toString(),
      shippingInformation: json['shippingInformation']?.toString(),
      availabilityStatus: json['availabilityStatus']?.toString(),
      returnPolicy: json['returnPolicy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
      'thumbnail': thumbnail,
      'images': images,
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'returnPolicy': returnPolicy,
    };
  }

  ProductModel copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    String? brand,
    String? thumbnail,
    List<String>? images,
    String? warrantyInformation,
    String? shippingInformation,
    String? availabilityStatus,
    String? returnPolicy,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      rating: rating ?? this.rating,
      stock: stock ?? this.stock,
      brand: brand ?? this.brand,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      warrantyInformation: warrantyInformation ?? this.warrantyInformation,
      shippingInformation: shippingInformation ?? this.shippingInformation,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      returnPolicy: returnPolicy ?? this.returnPolicy,
    );
  }
}
