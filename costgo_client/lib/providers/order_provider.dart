import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/models/order_model.dart';
import 'package:costgo_app/core/repositories/order_repository.dart';

// 현재 사용자의 주문 내역을 제공
final myOrdersProvider = FutureProvider<List<OrderModel>>((ref) {
  return ref.watch(orderRepositoryProvider).getMyOrders();
});

// [ADMIN] 모든 주문 내역을 제공
final allOrdersAdminProvider = FutureProvider<List<OrderModel>>((ref) {
  return ref.watch(orderRepositoryProvider).getAllOrdersAdmin();
});