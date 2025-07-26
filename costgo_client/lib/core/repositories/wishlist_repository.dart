import 'package:costgo_app/models/product_model.dart';
import 'package:costgo_app/providers/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wishlistRepositoryProvider = Provider(
  (ref) => WishlistRepository(dio: ref.watch(dioProvider)),
);

class WishlistRepository {
  final Dio _dio;

  WishlistRepository({required Dio dio}) : _dio = dio;

  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await _dio.get('/wishlist');
      return (response.data as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch wishlist: $e');
    }
  }

  Future<void> addToWishlist(String productId) async {
    try {
      await _dio.post('/wishlist/add', data: {'productId': productId});
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      await _dio.delete('/wishlist/remove/$productId');
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }
}