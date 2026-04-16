// lib/src/presentation/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../blocs/admin/admin_bloc.dart';
import '../../../blocs/auth/auth_bloc.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(AdminLoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.go('/signin');
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminDashboardLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  Row(children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.attach_money,
                        label: 'Total Earnings',
                        value: '\$${state.totalEarnings.toStringAsFixed(2)}',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.inventory_2_outlined,
                        label: 'Products',
                        value: '${state.products.length}',
                        color: Colors.blue,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Earnings chart
                  if (state.earningsByCategory.isNotEmpty) ...[
                    const Text('Earnings by Category',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 250,
                      child: SfCircularChart(
                        legend: const Legend(isVisible: true, position: LegendPosition.bottom),
                        series: <CircularSeries>[
                          PieSeries<MapEntry<String, double>, String>(
                            dataSource: state.earningsByCategory.entries.toList(),
                            xValueMapper: (e, _) => e.key,
                            yValueMapper: (e, _) => e.value,
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Quick actions
                  const Text('Quick Actions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.add_box_outlined,
                        label: 'Add Product',
                        onTap: () => context.push('/admin/add-product'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.list_alt,
                        label: 'Manage Orders',
                        onTap: () => context.push('/admin/orders'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.local_offer_outlined,
                        label: 'Manage Offers',
                        onTap: () => context.push('/admin/offers'),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Products list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Products',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        onPressed: () => context.push('/admin/add-product'),
                      ),
                    ],
                  ),
                  ...state.products.map((p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: SizedBox(
                            width: 56, height: 56,
                            child: p.images.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: p.images.first,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.image_not_supported),
                          ),
                          title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${p.category} · \$${p.price.toStringAsFixed(2)} · Stock: ${p.quantity}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _confirmDelete(context, p.name, () {
                              context.read<AdminBloc>().add(AdminDeleteProduct(p));
                            }),
                          ),
                        ),
                      )),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String name, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); onConfirm(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF131921),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
