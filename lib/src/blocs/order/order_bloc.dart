// lib/src/blocs/order/order_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repo;

  OrderBloc({required OrderRepository repo})
      : _repo = repo,
        super(OrderInitial()) {
    on<OrderLoad>(_onLoad);
    on<OrderPlace>(_onPlace);
    on<OrderSearch>(_onSearch);
    on<OrderLoadById>(_onLoadById);
  }

  Future<void> _onLoad(OrderLoad e, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _repo.getUserOrders();
      emit(OrderLoaded(orders));
    } catch (ex) {
      emit(OrderError(ex.toString()));
    }
  }

  Future<void> _onPlace(OrderPlace e, Emitter<OrderState> emit) async {
    emit(OrderPlacing());
    try {
      final order = await _repo.placeOrder(items: e.items, address: e.address);
      emit(OrderPlaced(order));
    } catch (ex) {
      emit(OrderError(ex.toString()));
    }
  }

  Future<void> _onSearch(OrderSearch e, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _repo.searchOrders(e.query);
      emit(OrderSearchResult(orders, e.query));
    } catch (ex) {
      emit(OrderError(ex.toString()));
    }
  }

  Future<void> _onLoadById(OrderLoadById e, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _repo.getOrderById(e.orderId);
      final hasOrdered =
          await _repo.hasUserOrderedProduct(e.productIdForRating ?? '');
      emit(OrderDetailLoaded(order: order, canRate: hasOrdered));
    } catch (ex) {
      emit(OrderError(ex.toString()));
    }
  }
}
