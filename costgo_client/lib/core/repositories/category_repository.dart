import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category_model.dart';
import 'auth_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  // dioProvider를 사용하여 Dio 인스턴스를 가져옵니다.
  return CategoryRepository(ref.watch(dioProvider));
});

class CategoryRepository {
  final Dio _dio;
  final String _endpoint = '/categories'; // Node.js 서버의 카테고리 API 경로

  CategoryRepository(this._dio);

  // 모든 카테고리 목록 가져오기
  Future<List<MainCategory>> fetchCategories() async {
    try {
      final response = await _dio.get(_endpoint);
      // API 응답(List<dynamic>)을 List<MainCategory>로 변환
      final List<dynamic> data = response.data;
      return data.map((item) => MainCategory.fromJson(item)).toList();
    } on DioException catch (e) {
      throw Exception('카테고리 목록 로드 실패: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다.');
    }
  }

  // 새 메인 카테고리 추가
  Future<void> addMainCategory(String name) async {
    try {
      await _dio.post(_endpoint, data: {'name': name});
    } on DioException catch (e) {
      throw Exception('메인 카테고리 추가 실패: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // 메인 카테고리 수정
  Future<void> updateMainCategory(String id, String newName) async {
    try {
      await _dio.put('$_endpoint/$id', data: {'name': newName});
    } on DioException catch (e) {
      throw Exception('메인 카테고리 수정 실패: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // 메인 카테고리 삭제
  Future<void> deleteMainCategory(String id) async {
    try {
      await _dio.delete('$_endpoint/$id');
    } on DioException catch (e) {
      throw Exception('메인 카테고리 삭제 실패: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // 서브 카테고리 추가
  Future<void> addSubCategory(String mainCategoryId, String subCategoryName) async {
    try {
      await _dio.post('$_endpoint/$mainCategoryId/subcategories', data: {'name': subCategoryName});
    } on DioException catch (e) {
      throw Exception('서브 카테고리 추가 실패: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // 서브 카테고리 수정
  Future<void> updateSubCategory(String mainCategoryId, String subCategoryId, String newSubCategoryName) async {
    try {
      await _dio.put('$_endpoint/$mainCategoryId/subcategories/$subCategoryId', data: {'name': newSubCategoryName});
    } on DioException catch (e) {
      throw Exception('서브 카테고리 수정 실패: ${e.response?.data['message'] ?? e.message}');
    }
  }
  
  // 서브 카테고리 삭제
  Future<void> deleteSubCategory(String mainCategoryId, String subCategoryId) async {
    try {
      await _dio.delete('$_endpoint/$mainCategoryId/subcategories/$subCategoryId');
    } on DioException catch (e) {
      throw Exception('서브 카테고리 삭제 실패: ${e.response?.data['message'] ?? e.message}');
    }
  }
}