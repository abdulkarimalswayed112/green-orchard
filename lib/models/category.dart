// Named ProductCategory (not Category) to avoid clashing with Flutter's own
// `Category` annotation class.
class ProductCategory {
  final String id;
  final String name;
  final String? description;

  const ProductCategory({required this.id, required this.name, this.description});

  factory ProductCategory.fromJson(Map<String, dynamic> j) => ProductCategory(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        description: j['description'] as String?,
      );
}
