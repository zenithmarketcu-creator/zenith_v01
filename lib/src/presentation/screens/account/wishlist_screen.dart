// lib/src/presentation/screens/account/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/wishlist/wishlist_bloc.dart';
import '../../widgets/product_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});
  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WishlistBloc>().add(WishlistLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Wishlist'),
      ),
      body: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, state) {
          if (state is WishlistLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is WishlistLoaded) {
            if (state.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Wishlist is empty', style: TextStyle(color: Colors.grey, fontSize: 18)),
                  ],
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.72,
                crossAxisSpacing: 8, mainAxisSpacing: 8,
              ),
              itemCount: state.items.length,
              itemBuilder: (_, i) => ProductCard(product: state.items[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
