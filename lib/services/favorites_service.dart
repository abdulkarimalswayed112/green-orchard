import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

/// FR6 — favorites synced with the backend.
class FavoritesService {
  final _db = Supabase.instance.client;

  Future<List<Product>> getFavorites() async {
    final data = await _db
        .from('favorites')
        .select('id, product:products(*, category:categories(name))');
    return data
        .where((row) => row['product'] != null)
        .map((row) => Product.fromJson(Map<String, dynamic>.from(row['product'] as Map)))
        .toList();
  }

  Future<void> add(String productId) =>
      _db.from('favorites').insert({'product_id': productId});

  Future<void> remove(String productId) =>
      _db.from('favorites').delete().eq('product_id', productId);
}
