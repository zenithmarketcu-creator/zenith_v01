// lib/src/blocs/order/order_event.dart
part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class OrderLoad extends OrderEvent {}

class OrderPlace extends OrderEvent {
  final List<Map<String, dynamic>> items;
  final String address;
  const OrderPlace({required this.items, required this.address});
  @override
  List<Object?> get props => [items, address];
}

class OrderSearch extends OrderEvent {
  final String query;
  const OrderSearch(this.query);
  @override
  List<Object?> get props => [query];
}

class OrderLoadById extends OrderEvent {
  final String orderId;
  final String? productIdForRating;
  const OrderLoadById(this.orderId, {this.productIdForRating});
  @override
  List<Object?> get props => [orderId, productIdForRating];
}
