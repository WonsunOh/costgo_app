// costgo_client/lib/features/main_app/category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/category_provider.dart';
import 'package:costgo_app/models/category_model.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 원본 데이터의 로딩/에러 상태를 확인하기 위해 categoryProvider를 watch
    final asyncCategories = ref.watch(categoryProvider);
    // 계층화된 데이터를 가져오기 위해 hierarchicalCategoryProvider를 watch
    final hierarchicalCategories = ref.watch(hierarchicalCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리'),
      ),
      body: asyncCategories.when(
        data: (_) {
          if (hierarchicalCategories.isEmpty) {
            return const Center(child: Text('카테고리가 없습니다.'));
          }
          return ListView.builder(
            itemCount: hierarchicalCategories.length,
            itemBuilder: (context, index) {
              final category = hierarchicalCategories[index];
              return _buildCategoryTile(context, category);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러: $err')),
      ),
    );
  }

  // ExpansionTile을 재귀적으로 생성하여 계층 구조를 표현하는 함수
  Widget _buildCategoryTile(BuildContext context, CategoryModel category) {
    if (category.children.isEmpty) {
      return ListTile(
        title: Text(category.name),
        onTap: () {
          // TODO: 해당 카테고리의 상품 목록 페이지로 이동
          print('${category.name} 선택됨');
        },
      );
    }

    return ExpansionTile(
      title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: category.children.map((subCategory) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: _buildCategoryTile(context, subCategory), // 재귀 호출
        );
      }).toList(),
    );
  }
}