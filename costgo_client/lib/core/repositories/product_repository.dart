// costgo_client/lib/core/repositories/product_repository.dart (새 파일)
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/dio_provider.dart';

import '../../models/product_model.dart';

// 일반 사용자용 ProductRepository 제공
final productRepositoryProvider = Provider(
  (ref) => ProductRepository(dio: ref.watch(dioProvider)),
);

class ProductRepository {
  final Dio _dio;

  ProductRepository({required Dio dio}) : _dio = dio;

  // 모든 상품 목록을 가져옵니다.
  Future<List<ProductModel>> getProducts() async {
    try {
      // '/products'는 백엔드의 일반 사용자용 API 엔드포인트입니다.
      final response = await _dio.get('/products');
      final List<dynamic> data = response.data;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
  
  // TODO: 특정 상품 조회, 카테고리별 상품 조회 등 필요한 메소드 추가

// 특정 ID의 상품 정보를 가져옵니다.
  Future<ProductModel> getProductById(String productId) async {
    try {
      final response = await _dio.get('/products/$productId');
      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch product by ID: $e');
    }
  }

  // 검색어로 상품 목록을 가져옵니다.
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await _dio.get('/products/search/$query');
      final List<dynamic> data = response.data;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}