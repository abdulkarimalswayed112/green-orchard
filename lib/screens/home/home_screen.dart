import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_error.dart';
import '../../core/theme.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/vitrine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../services/catalog_service.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_views.dart';
import 'filter_sheet.dart';
import 'vitrine_header.dart';

/// FR2 + FR3 + FR4 — vitrine info, categories, products, search & filters.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _catalog = CatalogService();
  final _search = TextEditingController();
  Timer? _debounce;

  Vitrine? _vitrine;
  List<ProductCategory> _categories = [];
  List<Product> _products = [];

  String? _categoryId;
  ProductFilter _filter = const ProductFilter();

  bool _loadingHeader = true;
  bool _loadingProducts = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loadingHeader = true;
      _error = null;
    });
    try {
      final results = await Future.wait<Object>([
        _catalog.getVitrine(),
        _catalog.getCategories(),
      ]);
      _vitrine = results[0] as Vitrine;
      _categories = results[1] as List<ProductCategory>;
    } catch (e) {
      _error = friendlyError(e);
    }
    if (!mounted) return;
    setState(() => _loadingHeader = false);
    if (_error == null) await _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _loadingProducts = true);
    try {
      final list = await _catalog.getProducts(
        search: _search.text.trim(),
        categoryId: _categoryId,
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
        availableOnly: _filter.availableOnly,
      );
      if (mounted) {
        setState(() {
          _products = list;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = friendlyError(e));
    } finally {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  void _onSearchChanged(String _) {
    setState(() {}); // show / hide the clear button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadProducts);
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<ProductFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => FilterSheet(initial: _filter),
    );
    if (result != null) {
      setState(() => _filter = result);
      _loadProducts();
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<CartProvider>().reset();
    context.read<FavoritesProvider>().reset();
    await context.read<AuthProvider>().logout();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _loadingHeader
          ? const LoadingView()
          : (_vitrine == null)
              ? ErrorView(message: _error ?? 'Store not found', onRetry: _loadAll)
              : RefreshIndicator(
                  color: AppColors.leaf,
                  onRefresh: _loadAll,
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                        sliver: SliverList.list(children: [
                          VitrineHeader(vitrine: _vitrine!),
                          const SizedBox(height: 16),
                          _searchBar(),
                          const SizedBox(height: 14),
                        ]),
                      ),
                      SliverToBoxAdapter(child: _categoryChips()),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Text('Fresh today', style: t.titleLarge),
                              const Spacer(),
                              if (!_loadingProducts)
                                Text('${_products.length} items',
                                    style: t.bodySmall?.copyWith(color: AppColors.muted)),
                            ],
                          ),
                        ),
                      ),
                      ..._productsSlivers(),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ),
                ),
    );
  }

  Widget _searchBar() => Row(
        children: [
          Expanded(
            child: TextField(
              controller: _search,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search fruits, juices…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          _loadProducts();
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Badge(
            isLabelVisible: _filter.isActive,
            smallSize: 10,
            backgroundColor: AppColors.citrus,
            child: IconButton.filled(
              tooltip: 'Filters',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.leafTint,
                foregroundColor: AppColors.leaf,
                minimumSize: const Size(54, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _openFilters,
              icon: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      );

  Widget _categoryChips() {
    final chips = <(String?, String)>[
      (null, 'All'),
      ..._categories.map((c) => (c.id, c.name)),
    ];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (id, label) = chips[i];
          final selected = _categoryId == id;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            showCheckmark: false,
            selectedColor: AppColors.leaf,
            backgroundColor: Colors.white,
            side: BorderSide(color: selected ? AppColors.leaf : AppColors.line),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.ink,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            onSelected: (_) {
              setState(() => _categoryId = id);
              _loadProducts();
            },
          );
        },
      ),
    );
  }

  List<Widget> _productsSlivers() {
    if (_loadingProducts) {
      return const [SliverFillRemaining(hasScrollBody: false, child: LoadingView())];
    }
    if (_error != null) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(message: _error!, onRetry: _loadProducts),
        ),
      ];
    }
    if (_products.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            icon: Icons.search_off_rounded,
            title: 'No products found',
            subtitle: 'Try another word or clear the filters.',
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverGrid.builder(
          gridDelegate: productGridDelegate,
          itemCount: _products.length,
          itemBuilder: (_, i) => ProductCard(product: _products[i]),
        ),
      ),
    ];
  }
}
