import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_error.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../services/catalog_service.dart';
import '../../widgets/favorite_button.dart';
import '../../widgets/product_image.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/state_views.dart';

/// FR5 — shows the card's data instantly, then refreshes it from
/// GET /products?id=eq.{id}&select=*,category:categories(*)
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Product _product = widget.product;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    CatalogService().getProduct(widget.product.id).then((p) {
      if (mounted) setState(() => _product = p);
    }).catchError((_) {/* keep the card data; offline is fine here */});
  }

  Future<void> _addToCart() async {
    try {
      await context.read<CartProvider>().add(_product, quantity: _qty);
      if (!mounted) return;
      showMessage(context, 'Added $_qty × ${_product.name} to your cart');
    } catch (e) {
      if (mounted) showMessage(context, friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = _product;
    final busy = context.watch<CartProvider>().busy;
    final inCart = context.watch<CartProvider>().quantityOf(p.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: AppColors.leafTint,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: IconButton.filled(
                tooltip: 'Back',
                style: IconButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: AppColors.ink),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FavoriteButton(product: p),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${p.id}',
                child: ProductImage(url: p.imageUrl, radius: 0, iconSize: 96),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
            sliver: SliverList.list(children: [
              Wrap(
                spacing: 8,
                children: [
                  if (p.categoryName != null)
                    _Pill(p.categoryName!, AppColors.leafTint, AppColors.leafDark),
                  p.isAvailable
                      ? const _Pill('In stock', AppColors.citrusTint, AppColors.citrusDark)
                      : const _Pill('Out of stock', AppColors.ink, Colors.white),
                ],
              ),
              const SizedBox(height: 14),
              Text(p.name, style: t.headlineMedium),
              const SizedBox(height: 8),
              Text(money(p.price),
                  style: t.headlineSmall?.copyWith(color: AppColors.leaf)),
              const SizedBox(height: 16),
              Text(p.description.isEmpty ? 'No description yet.' : p.description,
                  style: t.bodyLarge?.copyWith(color: const Color(0xFF444F45), height: 1.6)),
              if (inCart > 0) ...[
                const SizedBox(height: 16),
                Text('$inCart already in your cart',
                    style: t.bodySmall?.copyWith(color: AppColors.muted)),
              ],
            ]),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              QuantityStepper(
                value: _qty,
                buttonSize: 44,
                onChanged: p.isAvailable ? (v) => setState(() => _qty = v) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: (!p.isAvailable || busy) ? null : _addToCart,
                  child: busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                      : Text(p.isAvailable ? 'Add to cart' : 'Unavailable'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const _Pill(this.text, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(text,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
      );
}
