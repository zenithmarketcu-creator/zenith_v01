// lib/src/blocs/admin/admin_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _adminRepo;
  final OrderRepository _orderRepo;
  final ProductRepository _productRepo;

  AdminBloc({
    required AdminRepository adminRepo,
    required OrderRepository orderRepo,
    required ProductRepository productRepo,
  })  : _adminRepo = adminRepo,
        _orderRepo = orderRepo,
        _productRepo = productRepo,
        super(AdminInitial()) {
    on<AdminLoadDashboard>(_onLoadDashboard);
    on<AdminAddProduct>(_onAddProduct);
    on<AdminDeleteProduct>(_onDeleteProduct);
    on<AdminLoadOrders>(_onLoadOrders);
    on<AdminUpdateOrderStatus>(_onUpdateOrderStatus);
    on<AdminLoadOffers>(_onLoadOffers);
    on<AdminAddOffer>(_onAddOffer);
    on<AdminDeleteOffer>(_onDeleteOffer);
  }

  Future<void> _onLoadDashboard(
      AdminLoadDashboard e, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final products = await _productRepo.getAllProducts();
      final totalEarnings = await _orderRepo.getTotalEarnings();
      final earningsByCategory = await _orderRepo.getEarningsByCategory();
      final offers = await _adminRepo.getOffers();
      emit(AdminDashboardLoaded(
        products: products,
        totalEarnings: totalEarnings,
        earningsByCategory: earningsByCategory,
        offers: offers,
      ));
    } catch (ex) {
      emit(AdminError(ex.toString()));
    }
  }

  Future<void> _onAddProduct(
      AdminAddProduct e, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await _adminRepo.addProduct(
        name: e.name,
        description: e.description,
        price: e.price,
        quantity: e.quantity,
        category: e.category,
        imageFiles: e.imageFiles,
      );
      add(AdminLoadDashboard());
    } catch (ex) {
      emit(AdminError(ex.toString()));
    }
  }

  Future<void> _onDeleteProduct(
      AdminDeleteProduct e, Emitter<AdminState> emit) async {
    try {
      await _adminRepo.deleteProduct(e.product);
      add(AdminLoadDashboard());
    } catch (ex) {
      emit(AdminError(ex.toString()));
    }
  }

  Future<void> _onLoadOrders(
      AdminLoadOrders e, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final orders = await _orderRepo.getAllOrders();
      emit(AdminOrdersLoaded(orders));
    } catch (ex) {
      emit(AdminError(ex.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
      AdminUpdateOrderStatus e, Emitter<AdminState> emit) async {
    try {
      await _orderRepo.updateOrderStatus(
          orderId: e.orderId, status: e.status);
      add(AdminLoadOrders());
    } catch (ex) {
      emit(AdminError(ex.toString()));
    }
  }

  Future<void> _onLoadOffers(
      AdminLoadOffers e, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final offers = await _adminRepo.getOffers();
      emit(AdminOffersLoaded(offers));
    } catch (ex) {
      emit(AdminError(ex.toString()));
    }
  }

  Future<void> _onAddOffer(AdminAddOffer e, Emitter<AdminState> emit) async {
    try {
      await _adminRepo.addOffer(e.imageFile);
      add(AdminLoadOffers());
    } catch (ex) {
      emit(AdminError(ex.toString()));
    }
  }

  Future<void> _onDeleteOffer(
      AdminDeleteOffer e, Emitter<AdminState> emit) async {
    try {
      await _adminRepo.deleteOffer(e.offer);
      add(AdminLoadOffers());
    } catch (ex) {
      emit(AdminError(ex.toString()));
    }
  }
}
