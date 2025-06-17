import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/repositories/category_repository.dart';
import '../models/category_model.dart';

// CategoryNotifier 클래스 수정
class CategoryNotifier extends StateNotifier<AsyncValue<List<MainCategory>>> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchCategories(); // 생성 시 카테고리 목록 로드
  }

  // 카테고리 목록 가져오기 (Repository 호출)
  Future<void> fetchCategories() async {
    // 재시도 등을 위해 명시적으로 로딩 상태 설정
    state = const AsyncValue.loading();
    try {
      final categories = await _repository.fetchCategories();
      // 성공 시 데이터로 상태 업데이트
      if (mounted) state = AsyncValue.data(categories);
    } catch (e, s) {
      // 실패 시 에러 상태로 업데이트
      if (mounted) state = AsyncValue.error(e, s);
    }
  }

  // 모든 CRUD 메소드는 Repository를 호출한 후 목록을 새로고침합니다.
  // 에러 발생 시 UI에서 처리할 수 있도록 Exception을 다시 던집니다(rethrow).
  Future<void> addMainCategory(String name) async {
    try {
      await _repository.addMainCategory(name);
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateMainCategory(String id, String newName) async {
    try {
      await _repository.updateMainCategory(id, newName);
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMainCategory(String id) async {
    try {
      await _repository.deleteMainCategory(id);
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> addSubCategory(String mainCategoryId, String subCategoryName) async {
    try {
      await _repository.addSubCategory(mainCategoryId, subCategoryName);
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSubCategory(String mainCategoryId, String subCategoryId, String newSubCategoryName) async {
    try {
      await _repository.updateSubCategory(mainCategoryId, subCategoryId, newSubCategoryName);
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSubCategory(String mainCategoryId, String subCategoryId) async {
    try {
      await _repository.deleteSubCategory(mainCategoryId, subCategoryId);
      await fetchCategories();
    } catch (e) {
      rethrow;
    }
  }
}

// StateNotifierProvider 정의 수정
final mainCategoryListProvider =
    StateNotifierProvider.autoDispose<CategoryNotifier, AsyncValue<List<MainCategory>>>((ref) {
  // CategoryRepository를 watch하여 Notifier에 주입
  return CategoryNotifier(ref.watch(categoryRepositoryProvider));
});