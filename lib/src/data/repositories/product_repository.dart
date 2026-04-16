// lib/src/data/repositories/product_repository.dart
import '../datasources/supabase_client.dart';
import '../models/product_model.dart';

class ProductRepository {
  final _client = SupabaseService.client;

  // ─── Get all products ───────────────────────────────────────
  Future<List<ProductModel>> getAllProducts() async {
    final data = await _client
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => ProductModel.fromMap(e)).toList();
  }

  // ─── Get products by category ────────────────────────────────
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final data = await _client
        .from('products')
        .select()
        .eq('category', category)
        .order('created_at', ascending: false);

    return (data as List).map((e) => ProductModel.fromMap(e)).toList();
  }

  // ─── Search products ─────────────────────────────────────────
  Future<List<ProductModel>> searchProducts(String query) async {
    final data = await _client
        .from('products')
        .select()
        .ilike('name', '%$query%')
        .order('avg_rating', ascending: false);

    return (data as List).map((e) => ProductModel.fromMap(e)).toList();
  }

  // ─── Get product by ID ───────────────────────────────────────
  Future<ProductModel> getProductById(String productId) async {
    final data = await _client
        .from('products')
        .select()
        .eq('id', productId)
        .single();

    return ProductModel.fromMap(data);
  }

  // ─── Deal of the day (highest rated) ─────────────────────────
  Future<ProductModel?> getDealOfTheDay() async {
    final data = await _client
        .from('products')
        .select()
        .order('avg_rating', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return ProductModel.fromMap(data);
  }

  // ─── Get products by IDs (recommendations / history) ─────────
  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final data = await _client
        .from('products')
        .select()
        .inFilter('id', ids);

    return (data as List).map((e) => ProductModel.fromMap(e)).toList();
  }

  // ─── Rate product ─────────────────────────────────────────────
  Future<void> rateProduct({
    required String productId,
    required double rating,
  }) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) throw Exception('Not authenticated');

    // Upsert: insert or update rating for this user+product
    await _client.from('ratings').upsert({
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
    }, onConflict: 'product_id,user_id');
    // Trigger on_rating_change auto-updates avg_rating on products table
  }

  // ─── Get user rating for a product ───────────────────────────
  Future<double?> getUserRating(String productId) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return null;

    final data = await _client
        .from('ratings')
        .select('rating')
        .eq('product_id', productId)
        .eq('user_id', userId)
        .maybeSingle();

    return data == null ? null : (data['rating'] as num).toDouble();
  }

  // ─── Browsing history ─────────────────────────────────────────
  Future<void> addToHistory(String productId) async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    await _client.from('browsing_history').upsert({
      'user_id': userId,
      'product_id': productId,
      'viewed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,product_id');
  }

  Future<List<ProductModel>> getBrowsingHistory() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return [];

    final data = await _client
        .from('browsing_history')
        .select('products(*)')
        .eq('user_id', userId)
        .order('viewed_at', ascending: false)
        .limit(20);

    return (data as List)
        .map((e) => ProductModel.fromMap(e['products'] as Map<String, dynamic>))
        .toList();
  }
}
