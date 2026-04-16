// lib/src/blocs/admin/admin_state.dart
part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final List<ProductModel> products;
  final double totalEarnings;
  final Map<String, double> earningsByCategory;
  final List<OfferModel> offers;

  const AdminDashboardLoaded({
    required this.products,
    required this.totalEarnings,
    required this.earningsByCategory,
    required this.offers,
  });

  @override
  List<Object?> get props =>
      [products, totalEarnings, earningsByCategory, offers];
}

class AdminOrdersLoaded extends AdminState {
  final List<OrderModel> orders;
  const AdminOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class AdminOffersLoaded extends AdminState {
  final List<OfferModel> offers;
  const AdminOffersLoaded(this.offers);

  @override
  List<Object?> get props => [offers];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
