import 'package:costgo_app/models/product_model.dart';
import 'package:costgo_app/providers/dio_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminProductRepositoryProvider = Provider(
  (ref) => AdminProductRepository(dio: ref.watch(dioProvider)),
);

class AdminProductRepository {
  final Dio _dio;
  AdminProductRepository({required Dio dio}) : _dio = dio;

  // READ: 관리자용 모든 상품 조회
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dio.get('/products/admin');
      return (response.data as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch admin products: $e');
    }
  }

  // CREATE: 새 상품 추가
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _dio.post(
        '/products/admin',
        data: product.toJson(),
      );
      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  // UPDATE: 기존 상품 수정
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await _dio.put(
        '/products/admin/${product.id}',
        data: product.toJson(),
      );
      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // DELETE: 상품 삭제
  Future<void> deleteProduct(String productId) async {
    try {
      await _dio.delete('/products/admin/$productId');
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }
}