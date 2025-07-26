// wonsunoh/costgo_app/costgo_app-9808e08a82f4563240a921b4f6a042a68c2c8c6a/costgo_client/lib/admin_panel/categories/catrgory_management_screen_admin.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/models/category_model.dart';
import 'package:costgo_app/providers/category_provider.dart';
import 'package:costgo_app/core/repositories/category_repository.dart';

class CategoryManagementScreenAdmin extends ConsumerWidget {
  const CategoryManagementScreenAdmin({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 'hierarchicalCategoryProvider'를 사용하여 계층화된 데이터를 가져옴
  final hierarchicalCategories = ref.watch(hierarchicalCategoryProvider);
  
  // 로딩 및 에러 상태는 원래의 categoryProvider를 통해 확인 가능
  final categoriesAsyncValue = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryDialog(context, ref),
          ),
        ],
      ),
      body: categoriesAsyncValue.when(
      // 데이터가 있을 때만 계층화된 리스트를 사용
      data: (_) => ListView.builder(
        itemCount: hierarchicalCategories.length,
        itemBuilder: (context, index) {
          final category = hierarchicalCategories[index];
          // 이제 category.children을 사용하여 하위 카테고리도 표시할 수 있습니다.
          return ExpansionTile(
            title: Text(category.name),
            children: category.children.map((subCategory) {
              return ListTile(
                title: Text('  - ${subCategory.name}'),
              );
            }).toList(),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('에러: $err')),
    ),
  );
}

  void _showCategoryDialog(BuildContext context, WidgetRef ref, {CategoryModel? category}) {
    final nameController = TextEditingController(text: category?.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category == null ? '새 카테고리 추가' : '카테고리 수정'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: '카테고리 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text;
                if (name.isEmpty) return;

                try {
                  if (category == null) {
                    // 2. 생성 기능 호출
                    await ref.read(categoryRepositoryProvider).createCategory(name);
                  } else {
                    // 2. 수정 기능 호출
                    await ref.read(categoryRepositoryProvider).updateCategory(category.id, name: name);
                  }
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('작업이 완료되었습니다.')));
                  // 3. 목록 새로고침
                  ref.invalidate(categoryProvider);
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }
}