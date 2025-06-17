import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_product_model.dart';
import '../repositories/admin_product_repository.dart';

// 상품 목록 상태를 관리하는 StateNotifier
class ProductAdminNotifier
    extends StateNotifier<AsyncValue<List<AdminProduct>>> {
  final AdminProductRepository _repository;

  ProductAdminNotifier(this._repository) : super(const AsyncValue.loading()) {
    fetchProducts(); // 생성 시 상품 목록 로드
  }

  // 상품 목록 가져오기
  Future<void> fetchProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _repository.fetchProducts();
      state = AsyncValue.data(products);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // 상품 추가
  Future<void> addProduct(AdminProduct product) async {
    state = const AsyncValue.loading(); // UI에 로딩 상태 표시
    try {
      await _repository.addProduct(product);
      await fetchProducts(); // 성공 후 목록 새로고침
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      throw e; // UI에서 에러를 잡을 수 있도록 rethrow
    }
  }

  // 상품 수정
  Future<void> updateProduct(AdminProduct product) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateProduct(product);
      await fetchProducts();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      throw e;
    }
  }

  // 상품 삭제
  Future<void> deleteProduct(String productId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteProduct(productId);
      await fetchProducts();
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      throw e;
    }
  }
}

// StateNotifierProvider 정의
final productAdminProvider = StateNotifierProvider.autoDispose<ProductAdminNotifier, AsyncValue<List<AdminProduct>>>((ref) {
  return ProductAdminNotifier(ref.watch(adminProductRepositoryProvider));
});

final productsByCategoryProvider = FutureProvider.autoDispose.family<List<AdminProduct>, String>((ref, categoryId) {
  return ref.watch(adminProductRepositoryProvider).fetchProductsByCategory(categoryId);
});

// --- 검색 관련 Provider들 ---

// 1. 현재 검색어를 관리하는 StateProvider
final adminProductSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

// 2. 검색어에 따라 필터링된 상품 목록을 제공하는 FutureProvider
final adminSearchedProductsProvider = FutureProvider.autoDispose.family<List<AdminProduct>, String>((ref, query) {
  if (query.trim().isEmpty) {
    return Future.value([]); // 검색어가 없으면 빈 리스트 반환
  }
  // 검색어가 있으면 AdminProductRepository의 검색 메소드 호출
  return ref.watch(adminProductRepositoryProvider).searchProducts(query);
});

