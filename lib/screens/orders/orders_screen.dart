import 'package:flutter/material.dart';

import '../../core/api_error.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/order_status.dart';
import '../../widgets/state_views.dart';
import 'order_details_screen.dart';

/// FR9 — previous orders and their current status.
class OrdersScreen extends StatefulWidget {
  /// Changes every time the tab is opened, so the list refreshes.
  final int refreshTick;

  const OrdersScreen({super.key, required this.refreshTick});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _service = OrderService();
  List<Order>? _orders;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(OrdersScreen old) {
    super.didUpdateWidget(old);
    if (old.refreshTick != widget.refreshTick) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = _orders == null);
    try {
      final list = await _service.getOrders();
      if (mounted) {
        setState(() {
          _orders = list;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const LoadingView();
    } else if (_orders == null) {
      body = ErrorView(message: _error ?? 'Couldn\'t load orders', onRetry: _load);
    } else if (_orders!.isEmpty) {
      body = const EmptyView(
        icon: Icons.receipt_long_outlined,
        title: 'No orders yet',
        subtitle: 'Orders you submit from your cart will show up here.',
      );
    } else {
      body = ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: _orders!.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _OrderTile(
          order: _orders![i],
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(orderId: _orders![i].id),
            ));
            _load(); // status may have changed while we were inside
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My orders'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: body is ListView
          ? RefreshIndicator(color: AppColors.leaf, onRefresh: _load, child: body)
          : body,
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderTile({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ${shortId(order.id)}',
                        style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${niceDate(order.createdAt)}\n'
                        '${order.itemCount} items · ${money(order.totalAmount)}',
                        style: t.bodySmall?.copyWith(color: AppColors.muted, height: 1.5)),
                  ],
                ),
              ),
              StatusBadge(status: order.status),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
