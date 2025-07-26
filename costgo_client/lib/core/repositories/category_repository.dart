// costgo_client/lib/core/repositories/category_repository.dart
import 'package:costgo_app/models/category_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/dio_provider.dart';

// CategoryRepositoryProvider (기존과 동일)
final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepository(dio: ref.watch(dioProvider)),
);

class CategoryRepository {
  final Dio _dio;

  CategoryRepository({required Dio dio}) : _dio = dio;

  // READ: 모든 카테고리 조회 (기존 메소드)
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      final List<dynamic> data = response.data;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // Dio 에러 발생 시 더 구체적인 메시지 반환
      throw Exception('카테고리 목록을 불러오는데 실패했습니다: ${e.response?.data['error'] ?? e.message}');
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // CREATE: 새로운 카테고리 생성
  Future<CategoryModel> createCategory(String name, {String? parentId}) async {
    try {
      final response = await _dio.post(
        '/categories',
        data: {
          'name': name,
          'parent': parentId,
        },
      );
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('카테고리 생성에 실패했습니다: ${e.response?.data['error'] ?? e.message}');
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // UPDATE: 기존 카테고리 수정
  Future<CategoryModel> updateCategory(String id, {String? name, String? parentId}) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (parentId != null) data['parent'] = parentId;

      final response = await _dio.put(
        '/categories/$id',
        data: data,
      );
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('카테고리 수정에 실패했습니다: ${e.response?.data['error'] ?? e.message}');
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
    }
  }

  // DELETE: 카테고리 삭제
  Future<void> deleteCategory(String id) async {
    try {
      await _dio.delete('/categories/$id');
    } on DioException catch (e) {
      throw Exception('카테고리 삭제에 실패했습니다: ${e.response?.data['error'] ?? e.message}');
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다: $e');
    }
  }
}