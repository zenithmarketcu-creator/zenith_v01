// lib/src/utils/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // ─── Categories ────────────────────────────────────────────
  static const List<String> categories = [
    'Mobiles',
    'Essentials',
    'Appliances',
    'Books',
    'Fashion',
  ];

  // ─── Category images (local assets) ───────────────────────
  static const Map<String, String> categoryImages = {
    'Mobiles': 'assets/images/mobiles.jpeg',
    'Essentials': 'assets/images/essentials.jpeg',
    'Appliances': 'assets/images/appliances.jpeg',
    'Books': 'assets/images/books.jpeg',
    'Fashion': 'assets/images/fashion.jpeg',
  };

  // ─── Order statuses ────────────────────────────────────────
  static const List<String> orderStatuses = [
    'Processing',
    'Shipped',
    'Delivered',
  ];

  // ─── Supabase bucket names ─────────────────────────────────
  static const String productImagesBucket = 'product-images';
  static const String offerImagesBucket = 'offer-images';

  // ─── Google Pay config ─────────────────────────────────────
  static const String googlePayMerchantId = 'YOUR_MERCHANT_ID';
  static const String googlePayMerchantName = 'Zenith Store';

  // ─── App colors ─────────────────────────────────────────────
  static const int primaryColorValue = 0xFFFF9800; // Amazon orange
  static const int secondaryColorValue = 0xFF131921; // Amazon dark
}
