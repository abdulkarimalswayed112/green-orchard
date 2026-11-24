import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_views.dart';

/// FR6 — favorites list synced with GET /favorites.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();

    Widget body;
    if (favs.loading && favs.items.isEmpty) {
      body = const LoadingView();
    } else if (favs.error != null && favs.items.isEmpty) {
      body = ErrorView(message: favs.error!, onRetry: favs.load);
    } else if (favs.items.isEmpty) {
      body = const EmptyView(
        icon: Icons.favorite_border_rounded,
        title: 'No favorites yet',
        subtitle: 'Tap the heart on any product to save it here.',
      );
    } else {
      body = GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        gridDelegate: productGridDelegate,
        itemCount: favs.items.length,
        itemBuilder: (_, i) => ProductCard(product: favs.items[i]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: RefreshIndicator(
        color: AppColors.leaf,
        onRefresh: favs.load,
        // Wrap non-scrolling states so pull-to-refresh still works.
        child: body is GridView
            ? body
            : LayoutBuilder(
                builder: (_, c) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(height: c.maxHeight, child: body),
                ),
              ),
      ),
    );
  }
}
