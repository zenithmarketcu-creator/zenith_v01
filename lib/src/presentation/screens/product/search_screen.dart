// lib/src/presentation/screens/product/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onSubmitted: (q) {
            if (q.trim().isNotEmpty) {
              context.read<ProductBloc>().add(ProductSearch(q.trim()));
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              if (_ctrl.text.trim().isNotEmpty) {
                context.read<ProductBloc>().add(ProductSearch(_ctrl.text.trim()));
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductSearchResult) {
            if (state.products.isEmpty) {
              return Center(
                child: Text('No results for "${state.query}"',
                    style: const TextStyle(color: Colors.grey)),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: 0.72,
                crossAxisSpacing: 8, mainAxisSpacing: 8,
              ),
              itemCount: state.products.length,
              itemBuilder: (_, i) => ProductCard(product: state.products[i]),
            );
          }
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey),
                SizedBox(height: 12),
                Text('Search for products', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
