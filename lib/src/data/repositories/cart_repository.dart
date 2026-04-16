// lib/src/data/repositories/cart_repository.dart
import '../datasources/supabase_client.dart';
import '../models/order_model.dart';

class CartRepository {
  final _client = SupabaseService.client;

  String get _userId {
    final id = SupabaseService.currentUserId;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  // ─── Get cart items ──────────────────────────────────────────
  Future<List<CartItemModel>> getCartItems() async {
    final data = await _client
        .from('cart_items')
        .select('*, products(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => CartItemModel.fromMap(e)).toList();
  }

  // ─── Add to cart ─────────────────────────────────────────────
  Future<void> addToCart({
    required String productId,
    int quantity = 1,
  }) async {
    // If already in cart, increment quantity
    final existing = await _client
        .from('cart_items')
        .select()
        .eq('user_id', _userId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from('cart_items')
          .update({'quantity': (existing['quantity'] as int) + quantity})
          .eq('id', existing['id']);
    } else {
      await _client.from('cart_items').insert({
        'user_id': _userId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  // ─── Update quantity ─────────────────────────────────────────
  Future<void> updateCartQuantity({
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId: cartItemId);
      return;
    }
    await _client
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', cartItemId);
  }

  // ─── Remove from cart ─────────────────────────────────────────
  Future<void> removeFromCart({required String cartItemId}) async {
    await _client
        .from('cart_items')
        .delete()
        .eq('id', cartItemId);
  }

  // ─── Remove by product ID ──────────────────────────────────────
  Future<void> removeProductFromCart(String productId) async {
    await _client
        .from('cart_items')
        .delete()
        .eq('user_id', _userId)
        .eq('product_id', productId);
  }

  // ─── Clear cart ───────────────────────────────────────────────
  Future<void> clearCart() async {
    await _client
        .from('cart_items')
        .delete()
        .eq('user_id', _userId);
  }

  // ─── Get save-for-later ───────────────────────────────────────
  Future<List<CartItemModel>> getSaveForLater() async {
    final data = await _client
        .from('save_for_later')
        .select('*, products(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => CartItemModel.fromMap(e)).toList();
  }

  // ─── Move cart → save for later ───────────────────────────────
  Future<void> moveToSaveForLater({
    required String cartItemId,
    required String productId,
  }) async {
    await removeFromCart(cartItemId: cartItemId);
    await _client.from('save_for_later').upsert({
      'user_id': _userId,
      'product_id': productId,
    }, onConflict: 'user_id,product_id');
  }

  // ─── Move save-for-later → cart ───────────────────────────────
  Future<void> moveToCart({
    required String saveForLaterId,
    required String productId,
  }) async {
    await _client
        .from('save_for_later')
        .delete()
        .eq('id', saveForLaterId);
    await addToCart(productId: productId);
  }

  // ─── Remove from save for later ───────────────────────────────
  Future<void> removeFromSaveForLater({required String saveForLaterId}) async {
    await _client
        .from('save_for_later')
        .delete()
        .eq('id', saveForLaterId);
  }
}
