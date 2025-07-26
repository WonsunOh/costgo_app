// costgo_client/lib/core/repositories/user_repository.dart
import 'package:costgo_app/models/user_model.dart';
import 'package:costgo_app/providers/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userRepositoryProvider = Provider(
  (ref) => UserRepository(dio: ref.watch(dioProvider)),
);

class UserRepository {
  final Dio _dio;

  UserRepository({required Dio dio}) : _dio = dio;

  // [ADMIN] 모든 사용자 목록 가져오기
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _dio.get('/users');
      final List<dynamic> data = response.data;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<UserModel> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/users/$userId', data: data);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update user: ${e.response?.data['error'] ?? e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> addToCart(String productId) async {
    try {
      await _dio.post('/users/cart/add', data: {'productId': productId});
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      await _dio.delete('/users/cart/remove/$productId');
    } catch (e) {
      throw Exception('Failed to remove from cart: $e');
    }
  }

  Future<void> updateCartQuantity(String productId, int quantity) async {
    try {
      await _dio.put('/users/cart/quantity', data: {
        'productId': productId,
        'quantity': quantity,
      });
    } catch (e) {
      throw Exception('Failed to update cart quantity: $e');
    }
  }
}