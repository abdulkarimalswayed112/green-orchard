import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart.dart';

/// FR7 — cart. The backend keeps the cart to one vitrine (ours).
class CartService {
  final _db = Supabase.instance.client;

  Future<Cart> getCart() async {
    final res = await _db.rpc('get_or_create_cart');
    return Cart.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<void> addItem(String cartId, String productId, int quantity) =>
      _db.from('cart_items').insert({
        'cart_id': cartId,
        'product_id': productId,
        'quantity': quantity,
      });

  Future<void> updateQuantity(String itemId, int quantity) =>
      _db.from('cart_items').update({'quantity': quantity}).eq('id', itemId);

  Future<void> removeItem(String itemId) =>
      _db.from('cart_items').delete().eq('id', itemId);

  Future<void> clear(String cartId) =>
      _db.from('cart_items').delete().eq('cart_id', cartId);
}
