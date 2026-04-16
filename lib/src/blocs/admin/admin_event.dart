// lib/src/blocs/admin/admin_event.dart
part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class AdminLoadDashboard extends AdminEvent {}

class AdminLoadOrders extends AdminEvent {}

class AdminLoadOffers extends AdminEvent {}

class AdminAddProduct extends AdminEvent {
  final String name, description, category;
  final double price;
  final int quantity;
  final List<dynamic> imageFiles;
  const AdminAddProduct({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.imageFiles,
  });
  @override
  List<Object?> get props => [name, description, category, price, quantity];
}

class AdminDeleteProduct extends AdminEvent {
  final ProductModel product;
  const AdminDeleteProduct(this.product);
  @override
  List<Object?> get props => [product];
}

class AdminUpdateOrderStatus extends AdminEvent {
  final String orderId;
  final int status;
  const AdminUpdateOrderStatus({required this.orderId, required this.status});
  @override
  List<Object?> get props => [orderId, status];
}

class AdminAddOffer extends AdminEvent {
  final dynamic imageFile;
  const AdminAddOffer(this.imageFile);
  @override
  List<Object?> get props => [imageFile];
}

class AdminDeleteOffer extends AdminEvent {
  final OfferModel offer;
  const AdminDeleteOffer(this.offer);
  @override
  List<Object?> get props => [offer];
}
