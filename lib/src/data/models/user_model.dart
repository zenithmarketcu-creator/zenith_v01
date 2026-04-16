// lib/src/data/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String address;
  final String type; // 'user' | 'admin'
  final List<String> cart;       // product IDs (convenience, from cart_items)
  final List<String> wishlist;   // product IDs
  final List<String> history;    // product IDs

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.address = '',
    this.type = 'user',
    this.cart = const [],
    this.wishlist = const [],
    this.history = const [],
  });

  bool get isAdmin => type == 'admin';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      type: map['type'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'address': address,
        'type': type,
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? address,
    String? type,
    List<String>? cart,
    List<String>? wishlist,
    List<String>? history,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      type: type ?? this.type,
      cart: cart ?? this.cart,
      wishlist: wishlist ?? this.wishlist,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [id, name, email, address, type];
}
