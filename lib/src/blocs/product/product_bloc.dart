// lib/src/blocs/product/product_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repo;

  ProductBloc({required ProductRepository repo})
      : _repo = repo,
        super(ProductInitial()) {
    on<ProductLoadAll>(_onLoadAll);
    on<ProductLoadByCategory>(_onLoadByCategory);
    on<ProductSearch>(_onSearch);
    on<ProductLoadById>(_onLoadById);
    on<ProductLoadDealOfDay>(_onLoadDealOfDay);
    on<ProductRate>(_onRate);
    on<ProductAddToHistory>(_onAddToHistory);
    on<ProductLoadHistory>(_onLoadHistory);
  }

  Future<void> _onLoadAll(ProductLoadAll e, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _repo.getAllProducts();
      emit(ProductLoaded(products));
    } catch (ex) {
      emit(ProductError(ex.toString()));
    }
  }

  Future<void> _onLoadByCategory(
      ProductLoadByCategory e, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _repo.getProductsByCategory(e.category);
      emit(ProductLoaded(products));
    } catch (ex) {
      emit(ProductError(ex.toString()));
    }
  }

  Future<void> _onSearch(
      ProductSearch e, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final products = await _repo.searchProducts(e.query);
      emit(ProductSearchResult(products, e.query));
    } catch (ex) {
      emit(ProductError(ex.toString()));
    }
  }

  Future<void> _onLoadById(
      ProductLoadById e, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await _repo.getProductById(e.productId);
      final userRating = await _repo.getUserRating(e.productId);
      final related = await _repo.getProductsByCategory(product.category);
      emit(ProductDetailLoaded(
        product: product,
        userRating: userRating,
        relatedProducts: related.where((p) => p.id != product.id).toList(),
      ));
    } catch (ex) {
      emit(ProductError(ex.toString()));
    }
  }

  Future<void> _onLoadDealOfDay(
      ProductLoadDealOfDay e, Emitter<ProductState> emit) async {
    try {
      final product = await _repo.getDealOfTheDay();
      if (product != null) emit(ProductDealOfDay(product));
    } catch (_) {}
  }

  Future<void> _onRate(ProductRate e, Emitter<ProductState> emit) async {
    try {
      await _repo.rateProduct(
          productId: e.productId, rating: e.rating);
      // Reload product detail
      add(ProductLoadById(e.productId));
    } catch (ex) {
      emit(ProductError(ex.toString()));
    }
  }

  Future<void> _onAddToHistory(
      ProductAddToHistory e, Emitter<ProductState> emit) async {
    await _repo.addToHistory(e.productId);
  }

  Future<void> _onLoadHistory(
      ProductLoadHistory e, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final history = await _repo.getBrowsingHistory();
      emit(ProductHistoryLoaded(history));
    } catch (ex) {
      emit(ProductError(ex.toString()));
    }
  }
}
