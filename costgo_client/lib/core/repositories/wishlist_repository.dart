import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepository(ref.watch(dioProvider));
});

class WishlistRepository {
  final Dio _dio;
  final String _endpoint = '/wishlist'; // Node.js 서버의 찜 목록 API 경로

  WishlistRepository(this._dio);

  // 현재 사용자의 찜 목록(상품 ID 리스트) 가져오기
  Future<List<String>> fetchWishlistIds() async {
    try {
      final response = await _dio.get(_endpoint);
      // 백엔드 API가 { "productIds": ["id1", "id2", ...] } 와 같은 형식으로 응답한다고 가정
      return List<String>.from(response.data['productIds'] as List<dynamic>? ?? []);
    } on DioException catch (e) {
      throw Exception('찜 목록을 불러오는 데 실패했습니다: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // 찜 목록에 상품 추가
  Future<void> addToWishlist(String productId) async {
    try {
      await _dio.post(_endpoint, data: {'productId': productId});
    } on DioException catch (e) {
      throw Exception('찜 목록 추가 실패: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // 찜 목록에서 상품 제거
  Future<void> removeFromWishlist(String productId) async {
    try {
      await _dio.delete('$_endpoint/$productId');
    } on DioException catch (e) {
      throw Exception('찜 목록 제거 실패: ${e.response?.data['message'] ?? e.message}');
    }
  }
}