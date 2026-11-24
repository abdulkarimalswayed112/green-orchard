import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_error.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/cart.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_image.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/state_views.dart';
import '../orders/order_details_screen.dart';

/// FR7 + FR8 — view / edit cart, estimated total, submit as an order.
class CartScreen extends StatelessWidget {
  final VoidCallback onOrderSubmitted;

  const CartScreen({super.key, required this.onOrderSubmitted});

  Future<void> _guard(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) showMessage(context, friendlyError(e));
    }
  }

  Future<bool> _confirm(BuildContext context, String title, String body, String ok) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(110, 44)),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ok),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _submit(BuildContext context, Cart cart) async {
    final ok = await _confirm(
      context,
      'Submit order?',
      'Your ${cart.totalItems} items (${money(cart.totalPrice)}) will be sent to the seller. '
          'No online payment is needed.',
      'Submit',
    );
    if (!ok || !context.mounted) return;

    try {
      final order = await context.read<CartProvider>().submit();
      if (!context.mounted) return;
      onOrderSubmitted();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded, color: AppColors.leaf, size: 48),
          title: const Text('Order submitted'),
          content: Text('Order ${shortId(order.id)} is now Pending. '
              'You\'ll see it update as the seller accepts and prepares it.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(130, 44)),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => OrderDetailsScreen(orderId: order.id),
                ));
              },
              child: const Text('Track order'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (context.mounted) showMessage(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final cart = provider.cart;
    final t = Theme.of(context).textTheme;

    Widget body;
    if (provider.loading) {
      body = const LoadingView();
    } else if (cart == null) {
      body = ErrorView(message: provider.error ?? 'Couldn\'t load your cart', onRetry: provider.load);
    } else if (cart.isEmpty) {
      body = const EmptyView(
        icon: Icons.shopping_basket_outlined,
        title: 'Your cart is empty',
        subtitle: 'Add fresh produce from the Home tab.',
      );
    } else {
      body = Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: AppColors.leaf,
              onRefresh: provider.load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                itemCount: cart.items.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Text('From Green Orchard Market · ${cart.totalItems} items',
                        style: t.bodySmall?.copyWith(color: AppColors.muted));
                  }
                  final item = cart.items[i - 1];
                  return _CartTile(
                    item: item,
                    busy: provider.busy,
                    onQty: (q) => _guard(context, () => provider.setQuantity(item, q)),
                    onRemove: () => _guard(context, () => provider.remove(item)),
                  );
                },
              ),
            ),
          ),
          _Summary(
            cart: cart,
            busy: provider.busy,
            onSubmit: () => _submit(context, cart),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My cart'),
        actions: [
          if (cart != null && !cart.isEmpty)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              onPressed: provider.busy
                  ? null
                  : () async {
                      if (await _confirm(context, 'Clear cart?',
                              'All items will be removed.', 'Clear') &&
                          context.mounted) {
                        _guard(context, provider.clear);
                      }
                    },
              child: const Text('Clear all', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: body,
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  final bool busy;
  final ValueChanged<int> onQty;
  final VoidCallback onRemove;

  const _CartTile({
    required this.item,
    required this.busy,
    required this.onQty,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ProductImage(url: item.imageUrl, width: 68, height: 68, iconSize: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text('${money(item.price)} each',
                        style: t.bodySmall?.copyWith(color: AppColors.muted)),
                    const SizedBox(height: 4),
                    item.isAvailable
                        ? Text(money(item.subtotal),
                            style: t.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700, color: AppColors.leaf))
                        : Text('Out of stock — remove to submit',
                            style: t.bodySmall?.copyWith(
                                color: AppColors.danger, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Remove ${item.name}',
                    visualDensity: VisualDensity.compact,
                    onPressed: busy ? null : onRemove,
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  ),
                  QuantityStepper(
                    value: item.quantity,
                    min: 1,
                    buttonSize: 32,
                    onChanged: busy ? null : onQty,
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}

class _Summary extends StatelessWidget {
  final Cart cart;
  final bool busy;
  final VoidCallback onSubmit;

  const _Summary({required this.cart, required this.busy, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Text('Estimated total', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(money(cart.totalPrice),
                  style: t.headlineSmall?.copyWith(color: AppColors.leaf)),
            ]),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('No online payment — the seller confirms your request.',
                  style: t.bodySmall?.copyWith(color: AppColors.muted)),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: (busy || cart.hasUnavailable) ? null : onSubmit,
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                  : const Text('Submit order'),
            ),
          ],
        ),
      ),
    );
  }
}
