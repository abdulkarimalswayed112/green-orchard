import '../core/format.dart';

class Product {
  final String id;
  final String? categoryId;
  final String name;
  final String description;
  final String? imageUrl;
  final double price;
  final bool isAvailable;
  final String? categoryName;

  const Product({
    required this.id,
    this.categoryId,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.price,
    required this.isAvailable,
    this.categoryName,
  });

  /// Works for `products?select=*,category:categories(name)` and for the
  /// nested product inside `favorites?select=id,product:products(*)`.
  factory Product.fromJson(Map<String, dynamic> j) {
    final cat = j['category'];
    return Product(
      id: j['id'] as String,
      categoryId: j['category_id'] as String?,
      name: j['name'] as String? ?? '',
      description: j['description'] as String? ?? '',
      imageUrl: j['image_url'] as String?,
      price: toDouble(j['price']),
      isAvailable: j['is_available'] as bool? ?? true,
      categoryName: cat is Map ? cat['name'] as String? : null,
    );
  }
}
