// lib/src/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/product/product_bloc.dart';
import '../../../blocs/cart/cart_bloc.dart';
import '../../../utils/constants/app_constants.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductLoadAll());
    context.read<ProductBloc>().add(ProductLoadDealOfDay());
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartBloc>().state;
    final cartCount = cartState is CartLoaded ? cartState.totalItems : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131921),
        title: GestureDetector(
          onTap: () => context.push('/search'),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Search Zenith',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        actions: [
          badges.Badge(
            badgeContent: Text(
              '$cartCount',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            showBadge: cartCount > 0,
            child: IconButton(
              icon:
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () => context.push('/cart'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            onPressed: () => context.push('/account'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductBloc>().add(ProductLoadAll());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner carousel ──────────────────────────
              _buildBannerCarousel(),

              // ── Categories ───────────────────────────────
              _buildCategoriesRow(context),

              // ── Deal of the Day ───────────────────────────
              _buildDealOfDay(context),

              // ── Products ──────────────────────────────────
              _buildProductsGrid(context),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    // Static banners — replace with real asset images
    final banners = [
      'assets/images/banner1.jpg',
      'assets/images/banner2.jpg',
      'assets/images/banner3.jpg',
    ];
    return CarouselSlider(
      options: CarouselOptions(
        height: 180,
        autoPlay: true,
        viewportFraction: 1.0,
        autoPlayInterval: const Duration(seconds: 3),
      ),
      items: banners
          .map((path) => Image.asset(path,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF232F3E),
                    child: const Center(
                        child:
                            Icon(Icons.image, color: Colors.white54, size: 40)),
                  )))
          .toList(),
    );
  }

  Widget _buildCategoriesRow(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('Shop by Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: AppConstants.categories.length,
              itemBuilder: (context, i) {
                final cat = AppConstants.categories[i];
                return GestureDetector(
                  onTap: () => context.push('/category/$cat'),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            AppConstants.categoryImages[cat] ?? '',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 60,
                              width: 60,
                              color: Colors.orange[100],
                              child: const Icon(Icons.category,
                                  color: Colors.orange),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(cat,
                            style: const TextStyle(fontSize: 11),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealOfDay(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (prev, curr) => curr is ProductDealOfDay,
      builder: (context, state) {
        if (state is! ProductDealOfDay) return const SizedBox.shrink();
        final product = state.product;
        return GestureDetector(
          onTap: () => context.push('/product/${product.id}'),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Deal of the Day',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB12704))),
                ),
                if (product.images.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: product.images.first,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const LoadingWidget(),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.image_not_supported),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB12704))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsGrid(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (prev, curr) =>
          curr is ProductLoaded || curr is ProductLoading,
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ));
        }
        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No products found'),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: Text('All Products',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, i) =>
                    ProductCard(product: state.products[i]),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
