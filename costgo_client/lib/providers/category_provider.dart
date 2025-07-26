// wonsunoh/costgo_app/costgo_app-9808e08a82f4563240a921b4f6a042a68c2c8c6a/costgo_client/lib/providers/category_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/repositories/category_repository.dart';
import '../models/category_model.dart';

// 1. 서버에서 받은 '평평한' 리스트를 제공하는 Provider (기존과 동일)
final categoryProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(categoryRepositoryProvider).getCategories();
});


// 2. '평평한' 리스트를 '계층' 구조로 가공하여 제공하는 새로운 Provider
final hierarchicalCategoryProvider = Provider<List<CategoryModel>>((ref) {
  // categoryProvider의 결과값을 watch
  final asyncCategories = ref.watch(categoryProvider);

  // 데이터가 성공적으로 로드되었을 때만 가공 로직 실행
  return asyncCategories.when(
    data: (flatList) {
      // 모든 카테고리를 ID를 키로 하는 맵으로 만들어 쉽게 찾을 수 있도록 함
      final map = {for (var cat in flatList) cat.id: cat};
      final topLevelCategories = <CategoryModel>[];

      for (final category in flatList) {
        // 부모 ID가 있는 경우, 맵에서 부모를 찾아 children 리스트에 자신을 추가
        if (category.parentId != null && map.containsKey(category.parentId)) {
          map[category.parentId]!.children.add(category);
        }
        // 부모 ID가 없는 경우, 최상위 카테고리이므로 별도 리스트에 추가
        else {
          topLevelCategories.add(category);
        }
      }
      return topLevelCategories;
    },
    // 로딩 중이거나 에러가 발생한 경우 빈 리스트 반환
    loading: () => [],
    error: (err, stack) => [],
  );
});