import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../screens/product/product_details_screen.dart';
import 'favorite_button.dart';
import 'product_image.dart';

/// Grid tile used on Home and Favorites.
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Opacity(
      opacity: product.isAvailable ? 1 : 0.6,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          )),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: 'product-${product.id}',
                          child: ProductImage(url: product.imageUrl),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: FavoriteButton(product: product, size: 34),
                      ),
                      if (!product.isAvailable)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.ink,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Text('Out of stock',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(money(product.price),
                        style: t.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700, color: AppColors.leaf)),
                    const Spacer(),
                    if (product.categoryName != null)
                      Flexible(
                        child: Text(product.categoryName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: t.bodySmall?.copyWith(color: AppColors.muted)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard grid settings so Home and Favorites look the same.
const productGridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 0.74,
);
