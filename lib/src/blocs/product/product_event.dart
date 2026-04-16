// lib/src/blocs/product/product_event.dart
part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class ProductLoadAll extends ProductEvent {}

class ProductLoadByCategory extends ProductEvent {
  final String category;
  const ProductLoadByCategory(this.category);
  @override
  List<Object?> get props => [category];
}

class ProductSearch extends ProductEvent {
  final String query;
  const ProductSearch(this.query);
  @override
  List<Object?> get props => [query];
}

class ProductLoadById extends ProductEvent {
  final String productId;
  const ProductLoadById(this.productId);
  @override
  List<Object?> get props => [productId];
}

class ProductLoadDealOfDay extends ProductEvent {}

class ProductRate extends ProductEvent {
  final String productId;
  final double rating;
  const ProductRate({required this.productId, required this.rating});
  @override
  List<Object?> get props => [productId, rating];
}

class ProductAddToHistory extends ProductEvent {
  final String productId;
  const ProductAddToHistory(this.productId);
  @override
  List<Object?> get props => [productId];
}

class ProductLoadHistory extends ProductEvent {}
