import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_error.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';

class FavoriteButton extends StatelessWidget {
  final Product product;
  final double size;

  const FavoriteButton({super.key, required this.product, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>().isFavorite(product.id);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(size / 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 3),
        onTap: () async {
          try {
            await context.read<FavoritesProvider>().toggle(product);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(friendlyError(e))));
            }
          }
        },
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: fav ? AppColors.citrus : AppColors.muted,
            size: size * 0.48,
            semanticLabel: fav ? 'Remove from favorites' : 'Add to favorites',
          ),
        ),
      ),
    );
  }
}
