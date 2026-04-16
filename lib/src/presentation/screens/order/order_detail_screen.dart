// lib/src/presentation/screens/order/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../blocs/order/order_bloc.dart';
import '../../../blocs/product/product_bloc.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(OrderLoadById(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Order Details'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderDetailLoaded) {
            final order = state.order;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Placed on ${DateFormat('MMM dd, yyyy').format(order.orderedAt)}',
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          _StatusStepper(status: order.status),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Items
                  const Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: SizedBox(
                            width: 60, height: 60,
                            child: item.product.images.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.product.images.first,
                                    fit: BoxFit.contain,
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.image_not_supported),
                          ),
                          title: Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text('Qty: ${item.quantity} · \$${item.price.toStringAsFixed(2)}'),
                          trailing: state.canRate
                              ? IconButton(
                                  icon: const Icon(Icons.star_outline, color: Color(0xFFFF9800)),
                                  onPressed: () => _showRatingDialog(context, item.product.id),
                                )
                              : null,
                        ),
                      )),
                  const SizedBox(height: 12),
                  // Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Order Summary',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total'),
                              Text('\$${order.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (order.address.isNotEmpty) ...[
                            const Divider(),
                            const Text('Delivery Address',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(order.address, style: const TextStyle(color: Colors.grey)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showRatingDialog(BuildContext context, String productId) {
    double selectedRating = 3;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rate Product'),
        content: RatingBar.builder(
          initialRating: 3,
          minRating: 1,
          itemCount: 5,
          itemSize: 40,
          itemBuilder: (_, __) => const Icon(Icons.star, color: Color(0xFFFF9800)),
          onRatingUpdate: (r) => selectedRating = r,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<ProductBloc>().add(
                    ProductRate(productId: productId, rating: selectedRating));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rating submitted!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  final int status;
  const _StatusStepper({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = ['Processing', 'Shipped', 'Delivered'];
    return Row(
      children: List.generate(steps.length, (i) {
        final done = i <= status;
        return Expanded(
          child: Column(
            children: [
              Row(children: [
                if (i > 0)
                  Expanded(child: Divider(color: done ? Colors.green : Colors.grey, thickness: 2)),
                Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: done ? Colors.green : Colors.grey, size: 20),
                if (i < steps.length - 1)
                  Expanded(child: Divider(color: i < status ? Colors.green : Colors.grey, thickness: 2)),
              ]),
              const SizedBox(height: 4),
              Text(steps[i], style: TextStyle(fontSize: 10, color: done ? Colors.green : Colors.grey)),
            ],
          ),
        );
      }),
    );
  }
}
