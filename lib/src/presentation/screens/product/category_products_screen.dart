// lib/src/presentation/screens/product/category_products_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_error_widget.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;
  const CategoryProductsScreen({super.key, required this.category});
  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductLoadByCategory(widget.category));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        foregroundColor: Colors.white,
        title: Text(widget.category),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<ProductBloc>().add(ProductLoadByCategory(widget.category)),
            );
          }
          if (state is ProductLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text('No products in this category'));
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
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
