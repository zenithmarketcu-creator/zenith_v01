// lib/src/blocs/cart/cart_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/cart_repository.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repo;

  CartBloc({required CartRepository repo})
      : _repo = repo,
        super(CartInitial()) {
    on<CartLoad>(_onLoad);
    on<CartAdd>(_onAdd);
    on<CartUpdateQuantity>(_onUpdateQuantity);
    on<CartRemoveItem>(_onRemoveItem);
    on<CartClear>(_onClear);
    on<CartMoveToSaveForLater>(_onMoveToSaveForLater);
    on<CartMoveToCart>(_onMoveToCart);
    on<CartRemoveSaveForLater>(_onRemoveSaveForLater);
  }

  Future<void> _onLoad(CartLoad e, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cartItems = await _repo.getCartItems();
      final saveForLater = await _repo.getSaveForLater();
      emit(CartLoaded(cartItems: cartItems, saveForLater: saveForLater));
    } catch (ex) {
      emit(CartError(ex.toString()));
    }
  }

  Future<void> _onAdd(CartAdd e, Emitter<CartState> emit) async {
    try {
      await _repo.addToCart(productId: e.productId, quantity: e.quantity);
      add(CartLoad());
    } catch (ex) {
      emit(CartError(ex.toString()));
    }
  }

  Future<void> _onUpdateQuantity(
      CartUpdateQuantity e, Emitter<CartState> emit) async {
    try {
      await _repo.updateCartQuantity(
          cartItemId: e.cartItemId, quantity: e.quantity);
      add(CartLoad());
    } catch (ex) {
      emit(CartError(ex.toString()));
    }
  }

  Future<void> _onRemoveItem(CartRemoveItem e, Emitter<CartState> emit) async {
    try {
      await _repo.removeFromCart(cartItemId: e.cartItemId);
      add(CartLoad());
    } catch (ex) {
      emit(CartError(ex.toString()));
    }
  }

  Future<void> _onClear(CartClear e, Emitter<CartState> emit) async {
    try {
      await _repo.clearCart();
      add(CartLoad());
    } catch (ex) {
      emit(CartError(ex.toString()));
    }
  }

  Future<void> _onMoveToSaveForLater(
      CartMoveToSaveForLater e, Emitter<CartState> emit) async {
    try {
      await _repo.moveToSaveForLater(
          cartItemId: e.cartItemId, productId: e.productId);
      add(CartLoad());
    } catch (ex) {
      emit(CartError(ex.toString()));
    }
  }

  Future<void> _onMoveToCart(CartMoveToCart e, Emitter<CartState> emit) async {
    try {
      await _repo.moveToCart(
          saveForLaterId: e.saveForLaterId, productId: e.productId);
      add(CartLoad());
    } catch (ex) {
      emit(CartError(ex.toString()));
    }
  }

  Future<void> _onRemoveSaveForLater(
      CartRemoveSaveForLater e, Emitter<CartState> emit) async {
    try {
      await _repo.removeFromSaveForLater(saveForLaterId: e.saveForLaterId);
      add(CartLoad());
    } catch (ex) {
      emit(CartError(ex.toString()));
    }
  }
}
