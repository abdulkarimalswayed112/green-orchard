import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';

/// FR8 + FR9 — submit, history, tracking.
class OrderService {
  final _db = Supabase.instance.client;

  /// Atomic on the server: validates, snapshots prices, empties the cart.
  Future<Order> submit() async {
    final res = await _db.rpc('submit_order');
    return Order.fromJson(Map<String, dynamic>.from(res as Map));
  }

  Future<List<Order>> getOrders() async {
    final data = await _db
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);
    return data.map(Order.fromJson).toList();
  }

  Future<Order> getOrder(String id) async {
    final data = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .single();
    return Order.fromJson(data);
  }
}
