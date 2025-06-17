// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CategoryManagementScreenAdmin extends ConsumerWidget {
  const CategoryManagementScreenAdmin({super.key});

  // --- Dialog Methods ---

  // 메인 카테고리 추가 또는 수정 다이얼로그
  Future<void> _showAddOrEditMainCategoryDialog(BuildContext context, WidgetRef ref, {MainCategory? existingCategory}) async {
    final bool isEditMode = existingCategory != null;
    final nameController = TextEditingController(text: isEditMode ? existingCategory.name : '');
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;
        return StatefulBuilder( // 다이얼로그 내에서 상태 변경(로딩)을 위해 StatefulBuilder 사용
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditMode ? '메인 카테고리 수정' : '새 메인 카테고리 추가'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '카테고리 이름'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '카테고리 이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true); // 로딩 시작
                      final notifier = ref.read(mainCategoryListProvider.notifier);
                      final newName = nameController.text.trim();
                      try {
                        if (isEditMode) {
                          await notifier.updateMainCategory(existingCategory.id, newName);
                        } else {
                          await notifier.addMainCategory(newName);
                        }
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('카테고리가 성공적으로 ${isEditMode ? "수정" : "추가"}되었습니다.')),
                        );
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('오류 발생: ${e.toString()}')),
                        );
                      } finally {
                        if(dialogContext.mounted) setState(() => isLoading = false);
                      }
                    }
                  },
                  child: isLoading ? const SizedBox(width:18, height: 18, child: CircularProgressIndicator(strokeWidth: 2,)) : Text(isEditMode ? '수정' : '추가'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  // 서브 카테고리 추가 또는 수정 다이얼로그
  Future<void> _showAddOrEditSubCategoryDialog(BuildContext context, WidgetRef ref, String mainCategoryId, {SubCategory? existingSubCategory}) async {
    final bool isEditMode = existingSubCategory != null;
    final nameController = TextEditingController(text: isEditMode ? existingSubCategory.name : '');
    final formKey = GlobalKey<FormState>();

     return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditMode ? '서브 카테고리 수정' : '새 서브 카테고리 추가'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '서브 카테고리 이름'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? '이름을 입력해주세요.' : null,
                ),
              ),
              actions: <Widget>[
                TextButton(child: const Text('취소'), onPressed: () => Navigator.of(dialogContext).pop()),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true);
                      final notifier = ref.read(mainCategoryListProvider.notifier);
                      final newName = nameController.text.trim();
                       try {
                        if (isEditMode) {
                          await notifier.updateSubCategory(mainCategoryId, existingSubCategory.id, newName);
                        } else {
                          await notifier.addSubCategory(mainCategoryId, newName);
                        }
                        if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('서브 카테고리가 성공적으로 ${isEditMode ? "수정" : "추가"}되었습니다.')),
                        );
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('오류 발생: ${e.toString()}')),
                        );
                      } finally {
                        if (dialogContext.mounted) setState(() => isLoading = false);
                      }
                    }
                  },
                  child: isLoading ? const SizedBox(width:18, height: 18, child: CircularProgressIndicator(strokeWidth: 2,)) : Text(isEditMode ? '수정' : '추가'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  // 삭제 확인 다이얼로그
  Future<void> _showDeleteConfirmDialog(BuildContext context, WidgetRef ref, {required MainCategory mainCategory, SubCategory? subCategory}) async {
    final bool isMain = subCategory == null;
    final String categoryName = isMain ? mainCategory.name : subCategory.name;

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
          title: Text('${isMain ? "메인" : "서브"} 카테고리 삭제 확인'),
          content: Text("'$categoryName' 카테고리를 정말 삭제하시겠습니까?\n${isMain ? '하위의 모든 서브 카테고리도 함께 삭제됩니다.' : ''}\n(연관된 상품의 카테고리는 변경되지 않습니다.)"),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(dialogContext, false), child: const Text("취소")), 
            TextButton(onPressed: ()=>Navigator.pop(dialogContext, true), style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error), child: const Text("삭제"))
          ],
        )
    );

    if (confirmDelete == true) {
      final notifier = ref.read(mainCategoryListProvider.notifier);
       try {
        if (isMain) {
          await notifier.deleteMainCategory(mainCategory.id);
        } else {
          await notifier.deleteSubCategory(mainCategory.id, subCategory.id);
        }
        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'$categoryName' 카테고리가 삭제되었습니다.")),
        );
      } catch (e) {
        if(!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 중 오류 발생: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(mainCategoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
        centerTitle: true,
        actions: [
          asyncCategories.maybeWhen(
            data: (_) => IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: '새 메인 카테고리 추가',
              onPressed: () => _showAddOrEditMainCategoryDialog(context, ref),
            ),
            orElse: () => const SizedBox(width: 48), // 로딩/에러 시 빈 공간 (레이아웃 유지)
          ),
        ],
      ),
      body: asyncCategories.when(
        data: (mainCategories) {
          if (mainCategories.isEmpty) {
            return const Center(child: Text('등록된 카테고리가 없습니다.'));
          }
          return RefreshIndicator( // 당겨서 새로고침 기능 추가
            onRefresh: () => ref.refresh(mainCategoryListProvider.notifier).fetchCategories(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: mainCategories.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final mainCategory = mainCategories[index];
                return ExpansionTile(
                  key: ValueKey(mainCategory.id),
                  leading: const Icon(Icons.category_outlined),
                  title: Text(mainCategory.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_box_outlined, size: 20, color: Colors.blue),
                        tooltip: '서브 카테고리 추가',
                        onPressed: () => _showAddOrEditSubCategoryDialog(context, ref, mainCategory.id),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.orange),
                        tooltip: '메인 카테고리 수정',
                        onPressed: () => _showAddOrEditMainCategoryDialog(context, ref, existingCategory: mainCategory),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        tooltip: '메인 카테고리 삭제',
                        onPressed: () => _showDeleteConfirmDialog(context, ref, mainCategory: mainCategory),
                      ),
                    ],
                  ),
                  children: mainCategory.subCategories.isEmpty
      ? [ // 서브 카테고리가 없을 때
          const ListTile(
            title: Text('서브 카테고리가 없습니다.', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            contentPadding: EdgeInsets.only(left: 72.0), // 들여쓰기
          )
        ]
      : mainCategory.subCategories.map((subCategory) { // 서브 카테고리가 있을 때
          return ListTile(
            key: ValueKey(subCategory.id),
            leading: const Padding(
              padding: EdgeInsets.only(left: 40.0),
              child: Icon(Icons.subdirectory_arrow_right, size: 18, color: Colors.grey),
            ),
            title: Text(subCategory.name),
                          dense: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.orangeAccent),
                                tooltip: '서브 카테고리 수정',
                                onPressed: () => _showAddOrEditSubCategoryDialog(context, ref, mainCategory.id, existingSubCategory: subCategory),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                tooltip: '서브 카테고리 삭제',
                                onPressed: () => _showDeleteConfirmDialog(context, ref, mainCategory: mainCategory, subCategory: subCategory),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('카테고리 로드 중 오류 발생: $err'),
              const SizedBox(height: 10),
              ElevatedButton(
                // invalidate 대신 fetchCategories 직접 호출
                onPressed: () => ref.read(mainCategoryListProvider.notifier).fetchCategories(),
                child: const Text('재시도'),
              )
            ],
          )
        ),
      ),
    );
  }
}