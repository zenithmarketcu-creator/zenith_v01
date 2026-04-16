// lib/src/data/models/cart_item_model.dart
import 'package:equatable/equatable.dart';
import 'product_model.dart';

class CartItemModel extends Equatable {
  final String id;
  final String userId;
  final ProductModel product;
  final int quantity;

  const CartItemModel({
    required this.id,
    required this.userId,
    required this.product,
    required this.quantity,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      product: ProductModel.fromMap(map['products'] as Map<String, dynamic>),
      quantity: (map['quantity'] as num).toInt(),
    );
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      userId: userId,
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, userId, product, quantity];
}

// lib/src/data/models/order_model.dart

class OrderItemModel extends Equatable {
  final String id;
  final String orderId;
  final ProductModel product;
  final int quantity;
  final double price;

  const OrderItemModel({
    required this.id,
    required this.orderId,
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      product: ProductModel.fromMap(map['products'] as Map<String, dynamic>),
      quantity: (map['quantity'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, orderId, product, quantity, price];
}

class OrderModel extends Equatable {
  final String id;
  final String userId;
  final double totalPrice;
  final int status; // 0=Processing, 1=Shipped, 2=Delivered
  final String address;
  final DateTime orderedAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    required this.address,
    required this.orderedAt,
    this.items = const [],
  });

  String get statusLabel {
    switch (status) {
      case 0:
        return 'Processing';
      case 1:
        return 'Shipped';
      case 2:
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      totalPrice: (map['total_price'] as num).toDouble(),
      status: (map['status'] as num).toInt(),
      address: map['address'] as String? ?? '',
      orderedAt: DateTime.parse(map['ordered_at'] as String),
      items: (map['order_items'] as List<dynamic>?)
              ?.map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  OrderModel copyWith({int? status}) {
    return OrderModel(
      id: id,
      userId: userId,
      totalPrice: totalPrice,
      status: status ?? this.status,
      address: address,
      orderedAt: orderedAt,
      items: items,
    );
  }

  @override
  List<Object?> get props => [id, userId, totalPrice, status, address, orderedAt];
}

// ============================================================

class OfferModel extends Equatable {
  final String id;
  final String imageUrl;

  const OfferModel({required this.id, required this.imageUrl});

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map['id'] as String,
      imageUrl: map['image_url'] as String,
    );
  }

  @override
  List<Object?> get props => [id, imageUrl];
}
