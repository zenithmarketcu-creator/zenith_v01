// lib/src/presentation/screens/account/browsing_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../widgets/product_card.dart';

class BrowsingHistoryScreen extends StatefulWidget {
  const BrowsingHistoryScreen({super.key});
  @override
  State<BrowsingHistoryScreen> createState() => _BrowsingHistoryScreenState();
}

class _BrowsingHistoryScreenState extends State<BrowsingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductLoadHistory());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: const Text('Browsing History'),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductHistoryLoaded) {
            if (state.history.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 80, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No browsing history yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
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
              itemCount: state.history.length,
              itemBuilder: (_, i) => ProductCard(product: state.history[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
