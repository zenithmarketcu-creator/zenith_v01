// lib/src/presentation/screens/product/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/product/product_bloc.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../../../blocs/wishlist/wishlist_bloc.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../data/models/product_model.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductLoadById(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ProductBloc>().add(ProductLoadById(widget.productId)),
            );
          }
          if (state is ProductDetailLoaded) {
            final product = state.product;
            final wishlistState = context.watch<WishlistBloc>().state;
            final isWishlisted = wishlistState is WishlistLoaded &&
                wishlistState.items.any((p) => p.id == product.id);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    color: Colors.white,
                    child: Stack(children: [
                      SizedBox(
                        height: 280,
                        child: PageView.builder(
                          itemCount: product.images.isEmpty ? 1 : product.images.length,
                          itemBuilder: (_, i) => product.images.isEmpty
                              ? const Icon(Icons.image_not_supported, size: 80, color: Colors.grey)
                              : CachedNetworkImage(
                                  imageUrl: product.images[i],
                                  fit: BoxFit.contain,
                                  placeholder: (_, __) => const LoadingWidget(),
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: GestureDetector(
                          onTap: () => context.read<WishlistBloc>().add(WishlistToggle(product.id)),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  // Info
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Row(children: [
                          RatingBarIndicator(
                            rating: product.avgRating, itemSize: 18,
                            itemBuilder: (_, __) => const Icon(Icons.star, color: Color(0xFFFF9800)),
                          ),
                          const SizedBox(width: 8),
                          Text('${product.avgRating.toStringAsFixed(1)} (${product.ratingCount})',
                              style: const TextStyle(color: Colors.blue, fontSize: 13)),
                        ]),
                        const Divider(height: 24),
                        Text('\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFB12704))),
                        const SizedBox(height: 4),
                        Text('In Stock: ${product.quantity}',
                            style: TextStyle(
                                color: product.quantity > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('About this item',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(product.description,
                          style: const TextStyle(color: Colors.black87, height: 1.5)),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  // Rating
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Rate this product',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      RatingBar.builder(
                        initialRating: state.userRating ?? 0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5, itemSize: 32,
                        itemBuilder: (_, __) => const Icon(Icons.star, color: Color(0xFFFF9800)),
                        onRatingUpdate: (r) => context.read<ProductBloc>()
                            .add(ProductRate(productId: product.id, rating: r)),
                      ),
                      if (state.userRating != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Your rating: ${state.userRating!.toInt()}/5',
                              style: const TextStyle(color: Colors.grey)),
                        ),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  // Buttons
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: product.quantity > 0
                              ? () {
                                  context.read<CartBloc>().add(CartAdd(productId: product.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Added to cart'), backgroundColor: Colors.green),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Add to Cart',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: product.quantity > 0
                              ? () {
                                  final authState = context.read<AuthBloc>().state;
                                  if (authState is AuthAuthenticated) {
                                    context.read<OrderBloc>().add(OrderPlace(
                                          items: [{'product': product, 'quantity': 1}],
                                          address: authState.user.address,
                                        ));
                                  }
                                  context.push('/orders');
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA41C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Buy Now',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ]),
                  ),
                  // Related
                  if (state.relatedProducts.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Related Products',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.relatedProducts.length,
                            itemBuilder: (_, i) => SizedBox(
                              width: 140,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ProductCard(product: state.relatedProducts[i]),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
