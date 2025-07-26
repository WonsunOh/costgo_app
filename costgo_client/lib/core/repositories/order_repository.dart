import 'package:costgo_app/models/order_model.dart';
import 'package:costgo_app/providers/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRepositoryProvider = Provider(
  (ref) => OrderRepository(dio: ref.watch(dioProvider)),
);

class OrderRepository {
  final Dio _dio;

  OrderRepository({required Dio dio}) : _dio = dio;
  
  Future<OrderModel> placeOrder({
    required List<Map<String, dynamic>> products,
    required double totalPrice,
    required String shippingAddress,
  }) async {
    try {
      final response = await _dio.post('/orders', data: {
        'products': products,
        'totalPrice': totalPrice,
        'shippingAddress': shippingAddress,
      });
      return OrderModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _dio.get('/orders/my-orders');
      return (response.data as List)
          .map((item) => OrderModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch my orders: $e');
    }
  }

  // --- Admin ---
  Future<List<OrderModel>> getAllOrdersAdmin() async {
    try {
      final response = await _dio.get('/orders/admin/all-orders');
      return (response.data as List)
          .map((item) => OrderModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all orders: $e');
    }
  }

  Future<OrderModel> updateOrderStatusAdmin(String orderId, String status) async {
    try {
      final response = await _dio.put(
        '/orders/admin/update-status/$orderId',
        data: {'status': status},
      );
      return OrderModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}