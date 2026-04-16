// lib/src/presentation/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../blocs/cart/cart_bloc.dart';
import '../../../blocs/order/order_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../data/models/order_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(CartLoad());
  }

  void _placeOrder(BuildContext context) {
    final cartState = context.read<CartBloc>().state;
    final authState = context.read<AuthBloc>().state;
    if (cartState is! CartLoaded || authState is! AuthAuthenticated) return;

    final items = cartState.cartItems
        .map((item) => {'product': item.product, 'quantity': item.quantity})
        .toList();

    context.read<OrderBloc>().add(OrderPlace(
          items: items,
          address: authState.user.address,
        ));
    context.read<CartBloc>().add(CartClear());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order placed!'), backgroundColor: Colors.green),
    );
    context.push('/orders');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Shopping Cart'),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartLoaded) {
            return Column(
              children: [
                Expanded(
                  child: state.cartItems.isEmpty && state.saveForLater.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                              SizedBox(height: 12),
                              Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(8),
                          children: [
                            if (state.cartItems.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text('Cart (${state.totalItems} items)',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              ...state.cartItems.map((item) => Dismissible(
                                    key: Key(item.id),
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 20),
                                      child: const Icon(Icons.delete, color: Colors.white),
                                    ),
                                    secondaryBackground: Container(
                                      color: Colors.blue,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(Icons.bookmark_border, color: Colors.white),
                                    ),
                                    onDismissed: (direction) {
                                      if (direction == DismissDirection.startToEnd) {
                                        context.read<CartBloc>().add(CartRemoveItem(item.id));
                                      } else {
                                        context.read<CartBloc>().add(
                                              CartMoveToSaveForLater(
                                                  cartItemId: item.id,
                                                  productId: item.product.id),
                                            );
                                      }
                                    },
                                    child: _CartItemTile(item: item),
                                  )),
                            ],
                            if (state.saveForLater.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Saved for Later',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                              ...state.saveForLater.map((item) => Dismissible(
                                    key: Key('sfl_${item.id}'),
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.only(left: 20),
                                      child: const Icon(Icons.delete, color: Colors.white),
                                    ),
                                    secondaryBackground: Container(
                                      color: Colors.green,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      child: const Icon(Icons.shopping_cart, color: Colors.white),
                                    ),
                                    onDismissed: (direction) {
                                      if (direction == DismissDirection.startToEnd) {
                                        context.read<CartBloc>().add(CartRemoveSaveForLater(item.id));
                                      } else {
                                        context.read<CartBloc>().add(
                                              CartMoveToCart(
                                                  saveForLaterId: item.id,
                                                  productId: item.product.id),
                                            );
                                      }
                                    },
                                    child: _CartItemTile(item: item, isSaved: true),
                                  )),
                            ],
                          ],
                        ),
                ),
                // Checkout bar
                if (state.cartItems.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total: \$${state.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('${state.totalItems} items',
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _placeOrder(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Checkout',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final bool isSaved;
  const _CartItemTile({required this.item, this.isSaved = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            SizedBox(
              width: 80, height: 80,
              child: item.product.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.product.images.first,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, color: Colors.grey),
                    )
                  : const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text('\$${item.product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Color(0xFFB12704))),
                  if (!isSaved)
                    Row(
                      children: [
                        const Text('Qty: ', style: TextStyle(color: Colors.grey)),
                        DropdownButton<int>(
                          value: item.quantity,
                          underline: const SizedBox(),
                          items: List.generate(10, (i) => i + 1)
                              .map((q) => DropdownMenuItem(
                                    value: q,
                                    child: Text('$q'),
                                  ))
                              .toList(),
                          onChanged: (q) {
                            if (q != null) {
                              context.read<CartBloc>().add(
                                    CartUpdateQuantity(
                                        cartItemId: item.id, quantity: q),
                                  );
                            }
                          },
                        ),
                      ],
                    ),
                  if (isSaved)
                    TextButton(
                      onPressed: () => context.read<CartBloc>().add(
                            CartMoveToCart(
                                saveForLaterId: item.id,
                                productId: item.product.id),
                          ),
                      child: const Text('Move to Cart'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
