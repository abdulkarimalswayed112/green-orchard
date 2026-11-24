import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/api_error.dart';
import '../../core/config.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/order_status.dart';
import '../../widgets/state_views.dart';

/// FR9 — one order: status timeline + items. Re-checks the status every
/// 15 s, so when the seller moves it to Accepted / Ready it updates live
/// during the demo, and tells the user with a SnackBar.
class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final _service = OrderService();
  Order? _order;
  String? _error;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(AppConfig.orderPollInterval, (_) => _load(silent: true));
  }

  Future<void> _load({bool silent = false}) async {
    try {
      final o = await _service.getOrder(widget.orderId);
      if (!mounted) return;
      final previous = _order?.status;
      setState(() {
        _order = o;
        _error = null;
      });
      if (previous != null && previous != o.status) {
        showMessage(context, 'Order status updated: ${o.status}');
      }
      if (o.status == 'Completed') _poll?.cancel();
    } catch (e) {
      if (!mounted) return;
      if (!silent || _order == null) setState(() => _error = friendlyError(e));
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final o = _order;

    return Scaffold(
      appBar: AppBar(
        title: Text(o == null ? 'Order' : 'Order ${shortId(o.id)}'),
        actions: [
          IconButton(
            tooltip: 'Refresh status',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: o == null
          ? (_error != null ? ErrorView(message: _error!, onRetry: _load) : const LoadingView())
          : RefreshIndicator(
              color: AppColors.leaf,
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text(niceDate(o.createdAt),
                                  style: t.bodySmall?.copyWith(color: AppColors.muted)),
                            ),
                            StatusBadge(status: o.status),
                          ]),
                          const SizedBox(height: 18),
                          StatusTimeline(status: o.status),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Items', style: t.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Column(
                        children: [
                          for (final item in o.items)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.productName,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              subtitle: Text('${item.quantity} × ${money(item.unitPrice)}'),
                              trailing: Text(money(item.subtotal),
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                            ),
                          const Divider(color: AppColors.line),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(children: [
                              Text('Total',
                                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(money(o.totalAmount),
                                  style: t.titleLarge?.copyWith(color: AppColors.leaf)),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
