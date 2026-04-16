// lib/src/blocs/wishlist/wishlist_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/wishlist_repository.dart';

part 'wishlist_event.dart';
part 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository _repo;

  WishlistBloc({required WishlistRepository repo})
      : _repo = repo,
        super(WishlistInitial()) {
    on<WishlistLoad>(_onLoad);
    on<WishlistAdd>(_onAdd);
    on<WishlistRemove>(_onRemove);
    on<WishlistToggle>(_onToggle);
  }

  Future<void> _onLoad(WishlistLoad e, Emitter<WishlistState> emit) async {
    emit(WishlistLoading());
    try {
      final items = await _repo.getWishlist();
      emit(WishlistLoaded(items));
    } catch (ex) {
      emit(WishlistError(ex.toString()));
    }
  }

  Future<void> _onAdd(WishlistAdd e, Emitter<WishlistState> emit) async {
    try {
      await _repo.addToWishlist(e.productId);
      add(WishlistLoad());
    } catch (ex) {
      emit(WishlistError(ex.toString()));
    }
  }

  Future<void> _onRemove(WishlistRemove e, Emitter<WishlistState> emit) async {
    try {
      await _repo.removeFromWishlist(e.productId);
      add(WishlistLoad());
    } catch (ex) {
      emit(WishlistError(ex.toString()));
    }
  }

  Future<void> _onToggle(WishlistToggle e, Emitter<WishlistState> emit) async {
    try {
      await _repo.toggleWishlist(e.productId);
      add(WishlistLoad());
    } catch (ex) {
      emit(WishlistError(ex.toString()));
    }
  }
}
