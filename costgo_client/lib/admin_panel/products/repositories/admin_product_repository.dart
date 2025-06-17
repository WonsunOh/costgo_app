import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/repositories/auth_repository.dart';
import '../models/admin_product_model.dart';

final adminProductRepositoryProvider = Provider<AdminProductRepository>((ref) {
  return AdminProductRepository(ref.watch(dioProvider));
});

class AdminProductRepository {
  final Dio _dio;
  final String _collectionPath = '/products';

  AdminProductRepository(this._dio);

  // 모든 상품 목록 가져오기 (API 호출)
  Future<List<AdminProduct>> fetchProducts() async {
    try {
      final response = await _dio.get(_collectionPath);
      final List<dynamic> productData = response.data;
      return productData.map((data) => AdminProduct.fromJson(data)).toList();
    } catch (e) {
      throw Exception('상품 목록을 불러오는 데 실패했습니다: $e');
    }
  }

  // 새 상품 추가
  Future<void> addProduct(AdminProduct product) async {
    try {
      await _dio.post(_collectionPath, data: product.toMap());
    } catch (e) {
      throw Exception('상품 추가 실패: $e');
    }
  }

  // 상품 수정
  Future<void> updateProduct(AdminProduct product) async {
    try {
      await _dio.put('$_collectionPath/${product.id}', data: product.toMap());
    } catch (e) {
      throw Exception('상품 수정 실패: $e');
    }
  }

  // 상품 삭제
  Future<void> deleteProduct(String productId) async {
    try {
      await _dio.delete('$_collectionPath/$productId');
    } catch (e) {
      throw Exception('상품 삭제 실패: $e');
    }
  }

  // 카테고리 ID로 상품 목록 가져오기
  Future<List<AdminProduct>> fetchProductsByCategory(String categoryId) async {
    try {
      // API 예시: GET /api/products?category=categoryId
      final response = await _dio.get(_collectionPath, queryParameters: {'category': categoryId});
      final List<dynamic> productData = response.data;
      return productData.map((data) => AdminProduct.fromJson(data)).toList();
    } catch (e) {
      throw Exception('카테고리별 상품 목록 로드 실패: $e');
    }
  }

  
  // ★★★ 상품 이름으로 검색하는 메소드 추가 ★★★
  Future<List<AdminProduct>> searchProducts(String query) async {
    try {
      // Node.js API에 검색 쿼리 전달 (예: GET /api/products?search=query)
      final response = await _dio.get(_collectionPath, queryParameters: {'search': query});
      final List<dynamic> productData = response.data;
      return productData.map((data) => AdminProduct.fromJson(data)).toList();
    } on DioException catch (e) {
      throw Exception('상품 검색 실패: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('상품 검색 중 알 수 없는 오류가 발생했습니다.');
    }
  }
}
