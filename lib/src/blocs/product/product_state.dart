// lib/src/blocs/product/product_state.dart
part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  const ProductLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class ProductSearchResult extends ProductState {
  final List<ProductModel> products;
  final String query;
  const ProductSearchResult(this.products, this.query);
  @override
  List<Object?> get props => [products, query];
}

class ProductDetailLoaded extends ProductState {
  final ProductModel product;
  final double? userRating;
  final List<ProductModel> relatedProducts;
  const ProductDetailLoaded({
    required this.product,
    this.userRating,
    required this.relatedProducts,
  });
  @override
  List<Object?> get props => [product, userRating, relatedProducts];
}

class ProductDealOfDay extends ProductState {
  final ProductModel product;
  const ProductDealOfDay(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductHistoryLoaded extends ProductState {
  final List<ProductModel> history;
  const ProductHistoryLoaded(this.history);
  @override
  List<Object?> get props => [history];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object?> get props => [message];
}
