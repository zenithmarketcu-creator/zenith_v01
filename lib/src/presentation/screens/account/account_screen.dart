// lib/src/presentation/screens/account/account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../../../blocs/wishlist/wishlist_bloc.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Account'),
      ),
      body: ListView(
        children: [
          // Profile header
          Container(
            color: const Color(0xFF232F3E),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFFFF9800),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(user.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    if (user.address.isNotEmpty)
                      Text(user.address, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _tile(context, Icons.shopping_bag_outlined, 'Your Orders', () => context.push('/orders')),
          _tile(context, Icons.favorite_border, 'Wishlist', () => context.push('/wishlist')),
          _tile(context, Icons.history, 'Browsing History', () => context.push('/history')),
          _tile(context, Icons.location_on_outlined, 'Update Address', () => _showAddressDialog(context, user.address)),
          const Divider(),
          _tile(
            context,
            Icons.logout,
            'Sign Out',
            () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              context.read<CartBloc>().add(CartLoad());
              context.read<WishlistBloc>().add(WishlistLoad());
              context.go('/signin');
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF131921)),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showAddressDialog(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Address'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Delivery Address', border: OutlineInputBorder()),
          maxLines: 2,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthAddressUpdateRequested(ctrl.text.trim()));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
