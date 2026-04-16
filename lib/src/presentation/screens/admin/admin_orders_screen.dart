// lib/src/presentation/screens/admin/admin_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../blocs/admin/admin_bloc.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Manage Orders'),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminOrdersLoaded) {
            if (state.orders.isEmpty) {
              return const Center(child: Text('No orders yet'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.orders.length,
              itemBuilder: (context, i) {
                final order = state.orders[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Order #${order.id.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(DateFormat('MMM dd').format(order.orderedAt),
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${order.items.length} items · \$${order.totalPrice.toStringAsFixed(2)}'),
                        const SizedBox(height: 8),
                        const Text('Status:', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Row(
                          children: [0, 1, 2].map((s) {
                            final labels = ['Processing', 'Shipped', 'Delivered'];
                            final isSelected = order.status == s;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: OutlinedButton(
                                  onPressed: () => context.read<AdminBloc>().add(
                                        AdminUpdateOrderStatus(orderId: order.id, status: s),
                                      ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: isSelected ? const Color(0xFF131921) : null,
                                    foregroundColor: isSelected ? Colors.white : null,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    textStyle: const TextStyle(fontSize: 11),
                                  ),
                                  child: Text(labels[s]),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
