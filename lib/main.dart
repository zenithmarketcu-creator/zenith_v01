// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'src/blocs/auth/auth_bloc.dart';
import 'src/blocs/product/product_bloc.dart';
import 'src/blocs/cart/cart_bloc.dart';
import 'src/blocs/order/order_bloc.dart';
import 'src/blocs/wishlist/wishlist_bloc.dart';
import 'src/blocs/admin/admin_bloc.dart';

import 'src/data/repositories/auth_repository.dart';
import 'src/data/repositories/product_repository.dart';
import 'src/data/repositories/cart_repository.dart';
import 'src/data/repositories/order_repository.dart';
import 'src/data/repositories/wishlist_repository.dart';
import 'src/data/repositories/admin_repository.dart';

import 'src/utils/router/app_router.dart';

// ─────────────────────────────────────────────────────────────
// ⚠️  REPLACE THESE WITH YOUR SUPABASE PROJECT VALUES
//     Dashboard → Settings → API
// ─────────────────────────────────────────────────────────────
const _supabaseUrl = 'https://qqbjvmqcvspdqabkufsv.supabase.co';
const _supabaseAnonKey = 'sb_publishable_8cDTD4Rg6Yru8rzJdtwLFQ_PQd-NIUp';
// ─────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Supabase
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // Init HydratedBloc storage (for persisting auth state)
  final directory = await getApplicationDocumentsDirectory();
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(directory.path),
  );
  HydratedBloc.storage = storage;

  runApp(const ZenithApp());
}

class ZenithApp extends StatelessWidget {
  const ZenithApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate repositories once
    final authRepo = AuthRepository();
    final productRepo = ProductRepository();
    final cartRepo = CartRepository();
    final orderRepo = OrderRepository();
    final wishlistRepo = WishlistRepository();
    final adminRepo = AdminRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepo),
        RepositoryProvider.value(value: productRepo),
        RepositoryProvider.value(value: cartRepo),
        RepositoryProvider.value(value: orderRepo),
        RepositoryProvider.value(value: wishlistRepo),
        RepositoryProvider.value(value: adminRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) =>
                AuthBloc(authRepository: authRepo)..add(AuthCheckRequested()),
          ),
          BlocProvider<ProductBloc>(
            create: (_) => ProductBloc(repo: productRepo),
          ),
          BlocProvider<CartBloc>(
            create: (_) => CartBloc(repo: cartRepo),
          ),
          BlocProvider<OrderBloc>(
            create: (_) => OrderBloc(repo: orderRepo),
          ),
          BlocProvider<WishlistBloc>(
            create: (_) => WishlistBloc(repo: wishlistRepo),
          ),
          BlocProvider<AdminBloc>(
            create: (_) => AdminBloc(
              adminRepo: adminRepo,
              orderRepo: orderRepo,
              productRepo: productRepo,
            ),
          ),
        ],
        child: _AppView(),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final router = AppRouter.router(context);
        return MaterialApp.router(
          title: 'Zenith',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF9800),
              primary: const Color(0xFFFF9800),
              secondary: const Color(0xFF131921),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF131921),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            useMaterial3: true,
          ),
          routerConfig: router,
        );
      },
    );
  }
}
