// lib/src/blocs/cart/cart_event.dart
part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartLoad extends CartEvent {}

class CartAdd extends CartEvent {
  final String productId;
  final int quantity;
  const CartAdd({required this.productId, this.quantity = 1});
  @override
  List<Object?> get props => [productId, quantity];
}

class CartUpdateQuantity extends CartEvent {
  final String cartItemId;
  final int quantity;
  const CartUpdateQuantity({required this.cartItemId, required this.quantity});
  @override
  List<Object?> get props => [cartItemId, quantity];
}

class CartRemoveItem extends CartEvent {
  final String cartItemId;
  const CartRemoveItem(this.cartItemId);
  @override
  List<Object?> get props => [cartItemId];
}

class CartClear extends CartEvent {}

class CartMoveToSaveForLater extends CartEvent {
  final String cartItemId;
  final String productId;
  const CartMoveToSaveForLater(
      {required this.cartItemId, required this.productId});
  @override
  List<Object?> get props => [cartItemId, productId];
}

class CartMoveToCart extends CartEvent {
  final String saveForLaterId;
  final String productId;
  const CartMoveToCart(
      {required this.saveForLaterId, required this.productId});
  @override
  List<Object?> get props => [saveForLaterId, productId];
}

class CartRemoveSaveForLater extends CartEvent {
  final String saveForLaterId;
  const CartRemoveSaveForLater(this.saveForLaterId);
  @override
  List<Object?> get props => [saveForLaterId];
}
