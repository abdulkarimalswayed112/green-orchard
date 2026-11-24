import '../core/format.dart';

/// Pending → Accepted → Ready → Completed (FR9)
const orderStatuses = ['Pending', 'Accepted', 'Ready', 'Completed'];

class OrderItem {
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  const OrderItem({
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) {
    final qty = (j['quantity'] as num?)?.toInt() ?? 1;
    final unit = toDouble(j['unit_price']);
    return OrderItem(
      productName: j['product_name'] as String? ?? '',
      unitPrice: unit,
      quantity: qty,
      subtotal: j['subtotal'] != null ? toDouble(j['subtotal']) : unit * qty,
    );
  }
}

class Order {
  final String id;
  final String status;
  final double totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.status,
    required this.totalAmount,
    this.createdAt,
    this.updatedAt,
    required this.items,
  });

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  /// Handles both shapes:
  ///  - rpc/submit_order → { order_id, items: [...] }
  ///  - orders?select=*,order_items(*) → { id, order_items: [...] }
  factory Order.fromJson(Map<String, dynamic> j) {
    final rawItems = (j['order_items'] ?? j['items']) as List? ?? [];
    return Order(
      id: (j['id'] ?? j['order_id']) as String,
      status: j['status'] as String? ?? 'Pending',
      totalAmount: toDouble(j['total_amount']),
      createdAt: DateTime.tryParse('${j['created_at']}'),
      updatedAt: DateTime.tryParse('${j['updated_at']}'),
      items: rawItems
          .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
