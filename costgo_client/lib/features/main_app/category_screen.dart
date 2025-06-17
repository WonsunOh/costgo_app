import 'package:costgo_app/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category_model.dart';
import '../product_list/product_list_screen.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {


  void _navigateToProductList(BuildContext context, String categoryId, String categoryName, {bool isMainCategoryView = false}) { // isMainCategory 플래그 추가 (선택적)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(
          categoryId: categoryId,
          categoryName: categoryName,
          // isMainCategoryView: isMainCategoryView, // 메인 카테고리에서 전체보기를 누른 경우 true, 서브카테고리는 false
        ),
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    // mainCategoryListProvider를 watch하여 AsyncValue<List<MainCategory>>를 가져옵니다.
    final AsyncValue<List<MainCategory>> asyncMainCategories = ref.watch(mainCategoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리'),
        centerTitle: true,
        elevation: 1,
      ),
      body: asyncMainCategories.when(
        data: (mainCategoryList) {
          // 데이터 로드 성공 시
          if (mainCategoryList.isEmpty) {
            return const Center(
              child: Text('등록된 카테고리가 없습니다.\n(관리자 패널에서 추가해주세요)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            );
          }
          // 이제 mainCategoryList는 List<MainCategory> 타입입니다.
          return ListView.builder(
        itemCount: mainCategoryList.length, // mainCategoryListProvider에서 카테고리 개수 가져오기
        itemBuilder: (context, index) {
          final mainCategory = mainCategoryList[index];
          if (mainCategory.subCategories.isEmpty) {
             // 서브 카테고리가 없는 경우
            return ListTile(
              leading: const Icon(Icons.label_outline, size: 28), // 임시 아이콘
              title: Text(mainCategory.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
              onTap: () {
                print('${mainCategory.name} (ID: ${mainCategory.id}) 선택됨. 상품 목록 화면으로 이동.');
                _navigateToProductList(context, mainCategory.id, mainCategory.name, isMainCategoryView: true); // 네비게이션 호출
              },
            );
          } else {
            // 서브 카테고리가 있는 경우 ExpansionTile 사용
            return ExpansionTile(
              leading: const Icon(Icons.label_important_outline, size: 28), // 임시 아이콘
              title: Text(mainCategory.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              childrenPadding: const EdgeInsets.only(left: 16.0),
              children: mainCategory.subCategories.map((subCategory) {
                return ListTile(
                  title: Text(subCategory.name, style: const TextStyle(fontSize: 15.5)),
                  contentPadding: const EdgeInsets.only(left: 40.0, right: 16.0),
                  onTap: () {
                    print('${subCategory.name} (ID: ${subCategory.id}) 선택됨. 상품 목록 화면으로 이동.');
                    _navigateToProductList(context, subCategory.id, '${mainCategory.name} > ${subCategory.name}', isMainCategoryView: false); // 네비게이션 호출
                  },
                );
              }).toList(),
            );
          }
        },
    );
  },
  loading: () => const Center(child: CircularProgressIndicator()), // 로딩 중 UI
        error: (error, stackTrace) { // 에러 발생 시 UI
          print("CategoryScreen - 에러: $error");
          print("CategoryScreen - 스택트레이스: $stackTrace");
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('카테고리 정보를 불러오는 중 오류가 발생했습니다.\n$error', textAlign: TextAlign.center),
            )
          );
        },
      ),
    );
  }
}