// lib/src/blocs/cart/cart_state.dart
part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}
class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemModel> cartItems;
  final List<CartItemModel> saveForLater;

  const CartLoaded({required this.cartItems, required this.saveForLater});

  double get totalPrice => cartItems.fold(
      0, (sum, item) => sum + item.product.price * item.quantity);

  int get totalItems => cartItems.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [cartItems, saveForLater];
}

class CartError extends CartState {
  final String message;
  const CartError(this.message);
  @override
  List<Object?> get props => [message];
}
