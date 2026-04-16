// lib/src/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/product/product_bloc.dart';
import '../../blocs/wishlist/wishlist_bloc.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final wishlistState = context.watch<WishlistBloc>().state;
    final isWishlisted = wishlistState is WishlistLoaded &&
        wishlistState.items.any((p) => p.id == product.id);

    return GestureDetector(
      onTap: () {
        context.read<ProductBloc>().add(ProductAddToHistory(product.id));
        context.push('/product/${product.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.images.first,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2)),
                            errorWidget: (_, __, ___) => const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey),
                          )
                        : const Icon(Icons.image_not_supported,
                            size: 40, color: Colors.grey),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => context
                            .read<WishlistBloc>()
                            .add(WishlistToggle(product.id)),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.avgRating,
                        itemSize: 12,
                        itemBuilder: (_, __) =>
                            const Icon(Icons.star, color: Color(0xFFFF9800)),
                      ),
                      const SizedBox(width: 4),
                      Text('(${product.ratingCount})',
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFFB12704))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
