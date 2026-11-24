import '../core/format.dart';

class CartItem {
  final String itemId;
  final String productId;
  final String name;
  final String? imageUrl;
  final double price;
  final int quantity;
  final double subtotal;
  final bool isAvailable;

  const CartItem({
    required this.itemId,
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.quantity,
    required this.subtotal,
    required this.isAvailable,
  });

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        itemId: j['item_id'] as String,
        productId: j['product_id'] as String,
        name: j['name'] as String? ?? '',
        imageUrl: j['image_url'] as String?,
        price: toDouble(j['price']),
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        subtotal: toDouble(j['subtotal']),
        isAvailable: j['is_available'] as bool? ?? true,
      );
}

/// Response of `rpc/get_or_create_cart`. Totals come from the server,
/// so the app never calculates prices itself.
class Cart {
  final String cartId;
  final int totalItems;
  final double totalPrice;
  final List<CartItem> items;

  const Cart({
    required this.cartId,
    required this.totalItems,
    required this.totalPrice,
    required this.items,
  });

  bool get isEmpty => items.isEmpty;
  bool get hasUnavailable => items.any((i) => !i.isAvailable);

  factory Cart.fromJson(Map<String, dynamic> j) => Cart(
        cartId: j['cart_id'] as String,
        totalItems: (j['total_items'] as num?)?.toInt() ?? 0,
        totalPrice: toDouble(j['total_price']),
        items: ((j['items'] as List?) ?? [])
            .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
