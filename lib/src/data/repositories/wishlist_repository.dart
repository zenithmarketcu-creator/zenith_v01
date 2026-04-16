// lib/src/data/repositories/wishlist_repository.dart
import '../datasources/supabase_client.dart';
import '../models/product_model.dart';

class WishlistRepository {
  final _client = SupabaseService.client;

  String get _userId {
    final id = SupabaseService.currentUserId;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  Future<List<ProductModel>> getWishlist() async {
    final data = await _client
        .from('wishlists')
        .select('products(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((e) => ProductModel.fromMap(e['products'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToWishlist(String productId) async {
    await _client.from('wishlists').upsert({
      'user_id': _userId,
      'product_id': productId,
    }, onConflict: 'user_id,product_id');
  }

  Future<void> removeFromWishlist(String productId) async {
    await _client
        .from('wishlists')
        .delete()
        .eq('user_id', _userId)
        .eq('product_id', productId);
  }

  Future<bool> isInWishlist(String productId) async {
    final data = await _client
        .from('wishlists')
        .select('id')
        .eq('user_id', _userId)
        .eq('product_id', productId)
        .maybeSingle();

    return data != null;
  }

  Future<void> toggleWishlist(String productId) async {
    final inList = await isInWishlist(productId);
    if (inList) {
      await removeFromWishlist(productId);
    } else {
      await addToWishlist(productId);
    }
  }
}
