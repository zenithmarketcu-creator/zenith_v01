// lib/src/data/models/product_model.dart
import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final String category;
  final List<String> images;
  final double avgRating;
  final int ratingCount;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.category,
    required this.images,
    this.avgRating = 0,
    this.ratingCount = 0,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toInt(),
      category: map['category'] as String,
      images: List<String>.from(map['images'] as List? ?? []),
      avgRating: (map['avg_rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'category': category,
        'images': images,
        'avg_rating': avgRating,
        'rating_count': ratingCount,
      };

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
    String? category,
    List<String>? images,
    double? avgRating,
    int? ratingCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      images: images ?? this.images,
      avgRating: avgRating ?? this.avgRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, description, price, quantity, category, images, avgRating, ratingCount];
}
