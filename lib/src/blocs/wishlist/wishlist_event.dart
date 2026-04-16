// lib/src/blocs/wishlist/wishlist_event.dart
part of 'wishlist_bloc.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();
  @override
  List<Object?> get props => [];
}

class WishlistLoad extends WishlistEvent {}

class WishlistAdd extends WishlistEvent {
  final String productId;
  const WishlistAdd(this.productId);
  @override
  List<Object?> get props => [productId];
}

class WishlistRemove extends WishlistEvent {
  final String productId;
  const WishlistRemove(this.productId);
  @override
  List<Object?> get props => [productId];
}

class WishlistToggle extends WishlistEvent {
  final String productId;
  const WishlistToggle(this.productId);
  @override
  List<Object?> get props => [productId];
}
