// lib/src/data/repositories/admin_repository.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../datasources/supabase_client.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class AdminRepository {
  final _client = SupabaseService.client;
  final _uuid = const Uuid();

  // ─── Upload images to Supabase Storage ────────────────────────
  /// Accepts List<File> (mobile) or List<Uint8List> (web)
  Future<List<String>> uploadProductImages(List<dynamic> files) async {
    final List<String> urls = [];

    for (final file in files) {
      final fileName =
          'products/${_uuid.v4()}.jpg';

      if (file is File) {
        await _client.storage
            .from('product-images')
            .upload(fileName, file,
                fileOptions: const FileOptions(
                  contentType: 'image/jpeg',
                  upsert: false,
                ));
      } else if (file is Uint8List) {
        await _client.storage
            .from('product-images')
            .uploadBinary(fileName, file,
                fileOptions: const FileOptions(
                  contentType: 'image/jpeg',
                  upsert: false,
                ));
      } else {
        throw ArgumentError('Unsupported file type: ${file.runtimeType}');
      }

      final url = _client.storage
          .from('product-images')
          .getPublicUrl(fileName);
      urls.add(url);
    }

    return urls;
  }

  // ─── Upload offer image ────────────────────────────────────────
  Future<String> uploadOfferImage(dynamic file) async {
    final fileName = 'offers/${_uuid.v4()}.jpg';

    if (file is File) {
      await _client.storage
          .from('offer-images')
          .upload(fileName, file,
              fileOptions: const FileOptions(contentType: 'image/jpeg'));
    } else if (file is Uint8List) {
      await _client.storage
          .from('offer-images')
          .uploadBinary(fileName, file,
              fileOptions: const FileOptions(contentType: 'image/jpeg'));
    }

    return _client.storage.from('offer-images').getPublicUrl(fileName);
  }

  // ─── Delete file from storage ──────────────────────────────────
  Future<void> deleteStorageFile(String bucket, String url) async {
    // Extract the path from the full URL
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    // URL pattern: .../storage/v1/object/public/{bucket}/{path}
    final bucketIndex = pathSegments.indexOf(bucket);
    if (bucketIndex == -1) return;
    final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
    await _client.storage.from(bucket).remove([filePath]);
  }

  // ─── Add product ──────────────────────────────────────────────
  Future<ProductModel> addProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String category,
    required List<dynamic> imageFiles, // File | Uint8List
  }) async {
    final imageUrls = await uploadProductImages(imageFiles);

    final data = await _client
        .from('products')
        .insert({
          'name': name,
          'description': description,
          'price': price,
          'quantity': quantity,
          'category': category,
          'images': imageUrls,
        })
        .select()
        .single();

    return ProductModel.fromMap(data);
  }

  // ─── Delete product ───────────────────────────────────────────
  Future<void> deleteProduct(ProductModel product) async {
    // Delete images from storage
    for (final url in product.images) {
      await deleteStorageFile('product-images', url);
    }

    await _client.from('products').delete().eq('id', product.id);
  }

  // ─── Update product quantity ──────────────────────────────────
  Future<void> updateProductQuantity({
    required String productId,
    required int quantity,
  }) async {
    await _client
        .from('products')
        .update({'quantity': quantity})
        .eq('id', productId);
  }

  // ─── Offers ───────────────────────────────────────────────────
  Future<List<OfferModel>> getOffers() async {
    final data = await _client
        .from('offers')
        .select()
        .order('created_at', ascending: false);

    return (data as List).map((e) => OfferModel.fromMap(e)).toList();
  }

  Future<OfferModel> addOffer(dynamic imageFile) async {
    final imageUrl = await uploadOfferImage(imageFile);

    final data = await _client
        .from('offers')
        .insert({'image_url': imageUrl})
        .select()
        .single();

    return OfferModel.fromMap(data);
  }

  Future<void> deleteOffer(OfferModel offer) async {
    await deleteStorageFile('offer-images', offer.imageUrl);
    await _client.from('offers').delete().eq('id', offer.id);
  }
}
