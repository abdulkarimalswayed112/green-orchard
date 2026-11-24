import 'package:flutter/foundation.dart';

import '../core/api_error.dart';
import '../models/cart.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';

/// Cart state shared by the product screen, the cart tab and the nav badge.
/// After every change we reload the cart from the server so totals stay
/// exactly what the backend calculates.
class CartProvider extends ChangeNotifier {
  final _cart = CartService();
  final _orders = OrderService();

  Cart? cart;
  bool loading = false; // first load
  bool busy = false; // an add / update / remove / submit is running
  String? error;

  int get count => cart?.totalItems ?? 0;

  int quantityOf(String productId) =>
      cart?.items.where((i) => i.productId == productId).firstOrNull?.quantity ?? 0;

  Future<void> load() async {
    loading = cart == null;
    error = null;
    notifyListeners();
    try {
      cart = await _cart.getCart();
    } catch (e) {
      error = friendlyError(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Adding a product that is already in the cart increases its quantity
  /// instead of inserting a duplicate row.
  Future<void> add(Product p, {int quantity = 1}) => _mutate(() async {
        cart ??= await _cart.getCart();
        final existing = cart!.items.where((i) => i.productId == p.id).firstOrNull;
        if (existing != null) {
          await _cart.updateQuantity(existing.itemId, existing.quantity + quantity);
        } else {
          await _cart.addItem(cart!.cartId, p.id, quantity);
        }
      });

  Future<void> setQuantity(CartItem item, int quantity) => quantity <= 0
      ? remove(item)
      : _mutate(() => _cart.updateQuantity(item.itemId, quantity));

  Future<void> remove(CartItem item) => _mutate(() => _cart.removeItem(item.itemId));

  Future<void> clear() => _mutate(() async {
        if (cart != null) await _cart.clear(cart!.cartId);
      });

  Future<Order> submit() async {
    busy = true;
    notifyListeners();
    try {
      final order = await _orders.submit();
      cart = await _cart.getCart(); // server empties it
      return order;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  /// Errors are rethrown so the screen can show a SnackBar.
  Future<void> _mutate(Future<void> Function() action) async {
    busy = true;
    notifyListeners();
    try {
      await action();
      cart = await _cart.getCart();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  void reset() {
    cart = null;
    error = null;
    notifyListeners();
  }
}
