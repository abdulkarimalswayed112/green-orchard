import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../models/vitrine.dart';

/// FR2–FR5 — vitrine, categories, products, search & filter, details.
class CatalogService {
  final _db = Supabase.instance.client;

  /// RLS returns exactly one vitrine: our group's (GET /rest/v1/vitrines).
  Future<Vitrine> getVitrine() async {
    final data = await _db.from('vitrines').select().single();
    return Vitrine.fromJson(data);
  }

  Future<List<ProductCategory>> getCategories() async {
    final data = await _db
        .from('categories')
        .select()
        .eq('is_active', true)
        .order('name', ascending: true);
    return data.map(ProductCategory.fromJson).toList();
  }

  /// Every filter is optional and they combine (FR4):
  /// name=ilike.*x* · category_id=eq.x · price=gte/lte · is_available=eq.true
  Future<List<Product>> getProducts({
    String? search,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    bool availableOnly = false,
  }) async {
    var query = _db.from('products').select('*, category:categories(name)');

    if (search != null && search.isNotEmpty) query = query.ilike('name', '%$search%');
    if (categoryId != null) query = query.eq('category_id', categoryId);
    if (minPrice != null) query = query.gte('price', minPrice);
    if (maxPrice != null) query = query.lte('price', maxPrice);
    if (availableOnly) query = query.eq('is_available', true);

    final data = await query.order('created_at', ascending: false);
    return data.map(Product.fromJson).toList();
  }

  Future<Product> getProduct(String id) async {
    final data = await _db
        .from('products')
        .select('*, category:categories(*)')
        .eq('id', id)
        .single();
    return Product.fromJson(data);
  }
}
