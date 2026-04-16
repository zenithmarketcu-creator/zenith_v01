// lib/src/blocs/order/order_state.dart
part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderPlacing extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> orders;
  const OrderLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderSearchResult extends OrderState {
  final List<OrderModel> orders;
  final String query;
  const OrderSearchResult(this.orders, this.query);

  @override
  List<Object?> get props => [orders, query];
}

class OrderPlaced extends OrderState {
  final OrderModel order;
  const OrderPlaced(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderDetailLoaded extends OrderState {
  final OrderModel order;
  final bool canRate;
  const OrderDetailLoaded({required this.order, required this.canRate});

  @override
  List<Object?> get props => [order, canRate];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
