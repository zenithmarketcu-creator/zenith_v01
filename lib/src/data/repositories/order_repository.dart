// lib/src/data/repositories/order_repository.dart
import '../datasources/supabase_client.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderRepository {
  final _client = SupabaseService.client;

  String get _userId {
    final id = SupabaseService.currentUserId;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  // ─── Place order ─────────────────────────────────────────────
  /// [items] is a list of {product, quantity} maps
  Future<OrderModel> placeOrder({
    required List<Map<String, dynamic>> items,
    // [{product: ProductModel, quantity: int}]
    required String address,
  }) async {
    final totalPrice = items.fold<double>(
      0,
      (sum, item) =>
          sum +
          (item['product'] as ProductModel).price *
              (item['quantity'] as int),
    );

    // Insert order
    final orderData = await _client
        .from('orders')
        .insert({
          'user_id': _userId,
          'total_price': totalPrice,
          'status': 0,
          'address': address,
        })
        .select()
        .single();

    final orderId = orderData['id'] as String;

    // Insert order items
    final orderItems = items
        .map((item) => {
              'order_id': orderId,
              'product_id': (item['product'] as ProductModel).id,
              'quantity': item['quantity'] as int,
              'price': (item['product'] as ProductModel).price,
            })
        .toList();

    await _client.from('order_items').insert(orderItems);

    return getOrderById(orderId);
  }

  // ─── Get orders for current user ──────────────────────────────
  Future<List<OrderModel>> getUserOrders() async {
    final data = await _client
        .from('orders')
        .select('''
          *,
          order_items(
            *,
            products(*)
          )
        ''')
        .eq('user_id', _userId)
        .order('ordered_at', ascending: false);

    return (data as List).map((e) => OrderModel.fromMap(e)).toList();
  }

  // ─── Get single order ─────────────────────────────────────────
  Future<OrderModel> getOrderById(String orderId) async {
    final data = await _client
        .from('orders')
        .select('''
          *,
          order_items(
            *,
            products(*)
          )
        ''')
        .eq('id', orderId)
        .single();

    return OrderModel.fromMap(data);
  }

  // ─── Search orders ────────────────────────────────────────────
  Future<List<OrderModel>> searchOrders(String query) async {
    // Get all orders, filter locally on product names
    final all = await getUserOrders();
    final q = query.toLowerCase();
    return all
        .where((o) =>
            o.items.any((i) => i.product.name.toLowerCase().contains(q)))
        .toList();
  }

  // ─── Check if user has ordered a product ──────────────────────
  Future<bool> hasUserOrderedProduct(String productId) async {
    final data = await _client
        .from('order_items')
        .select('id, orders!inner(user_id)')
        .eq('product_id', productId)
        .eq('orders.user_id', _userId)
        .limit(1);

    return (data as List).isNotEmpty;
  }

  // ─── Admin: get all orders ────────────────────────────────────
  Future<List<OrderModel>> getAllOrders() async {
    final data = await _client
        .from('orders')
        .select('''
          *,
          order_items(
            *,
            products(*)
          )
        ''')
        .order('ordered_at', ascending: false);

    return (data as List).map((e) => OrderModel.fromMap(e)).toList();
  }

  // ─── Admin: update order status ───────────────────────────────
  Future<void> updateOrderStatus({
    required String orderId,
    required int status,
  }) async {
    await _client
        .from('orders')
        .update({'status': status})
        .eq('id', orderId);
  }

  // ─── Admin: earnings by category ──────────────────────────────
  Future<Map<String, double>> getEarningsByCategory() async {
    final data = await _client
        .from('order_items')
        .select('price, quantity, products(category)');

    final Map<String, double> earnings = {};
    for (final item in data as List) {
      final category = item['products']['category'] as String;
      final amount =
          (item['price'] as num).toDouble() * (item['quantity'] as num).toInt();
      earnings[category] = (earnings[category] ?? 0) + amount;
    }
    return earnings;
  }

  // ─── Admin: total earnings ────────────────────────────────────
  Future<double> getTotalEarnings() async {
    final data = await _client
        .from('order_items')
        .select('price, quantity');

    double total = 0;
    for (final item in data as List) {
      total +=
          (item['price'] as num).toDouble() * (item['quantity'] as num).toInt();
    }
    return total;
  }
}
