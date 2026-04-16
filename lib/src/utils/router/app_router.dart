// lib/src/utils/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../presentation/screens/auth/sign_in_screen.dart';
import '../../presentation/screens/auth/sign_up_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/product/product_detail_screen.dart';
import '../../presentation/screens/product/category_products_screen.dart';
import '../../presentation/screens/product/search_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/order/orders_screen.dart';
import '../../presentation/screens/order/order_detail_screen.dart';
import '../../presentation/screens/account/account_screen.dart';
import '../../presentation/screens/account/wishlist_screen.dart';
import '../../presentation/screens/account/browsing_history_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/admin/admin_add_product_screen.dart';
import '../../presentation/screens/admin/admin_orders_screen.dart';
import '../../presentation/screens/admin/admin_offers_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter router(BuildContext context) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/home',
      redirect: (ctx, state) {
        final authState = ctx.read<AuthBloc>().state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isAdmin =
            isAuthenticated && authState.user.isAdmin;

        final goingToAuth = state.matchedLocation == '/signin' ||
            state.matchedLocation == '/signup';

        if (!isAuthenticated && !goingToAuth) return '/signin';
        if (isAuthenticated && goingToAuth) {
          return isAdmin ? '/admin' : '/home';
        }
        if (isAuthenticated &&
            isAdmin &&
            !state.matchedLocation.startsWith('/admin')) {
          return '/admin';
        }
        return null;
      },
      routes: [
        // ── Auth ────────────────────────────────────────
        GoRoute(path: '/signin', builder: (_, __) => const SignInScreen()),
        GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),

        // ── User ────────────────────────────────────────
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/product/:id',
          builder: (_, state) =>
              ProductDetailScreen(productId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/category/:name',
          builder: (_, state) =>
              CategoryProductsScreen(category: state.pathParameters['name']!),
        ),
        GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
        GoRoute(path: '/cart', builder: (_, __) => const CartScreen()),
        GoRoute(path: '/orders', builder: (_, __) => const OrdersScreen()),
        GoRoute(
          path: '/order/:id',
          builder: (_, state) =>
              OrderDetailScreen(orderId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
        GoRoute(path: '/wishlist', builder: (_, __) => const WishlistScreen()),
        GoRoute(
            path: '/history',
            builder: (_, __) => const BrowsingHistoryScreen()),

        // ── Admin ────────────────────────────────────────
        GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminDashboardScreen()),
        GoRoute(
            path: '/admin/add-product',
            builder: (_, __) => const AdminAddProductScreen()),
        GoRoute(
            path: '/admin/orders',
            builder: (_, __) => const AdminOrdersScreen()),
        GoRoute(
            path: '/admin/offers',
            builder: (_, __) => const AdminOffersScreen()),
      ],
    );
  }
}
