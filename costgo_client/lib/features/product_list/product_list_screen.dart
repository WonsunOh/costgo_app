import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin_panel/products/providers/admin_product_providers.dart';
import '../product/product_card.dart';
import '../product_detail/product_detail_screen.dart';

class ProductListScreen extends ConsumerWidget { // ConsumerStatefulWidget -> ConsumerWidget
  final String categoryId;
  final String categoryName;
  // isMainCategoryView 및 탭 관련 로직은 일단 단순화하여,
  // 특정 categoryId에 대한 상품 목록만 보여준다고 가정.
  // 탭 기능이 필요하면 이전 답변처럼 ConsumerStatefulWidget으로 구현.

  const ProductListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 카테고리 ID로 상품 목록을 가져오는 Provider를 watch
    final asyncProducts = ref.watch(productsByCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: asyncProducts.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(child: Text('"$categoryName" 카테고리에 상품이 없습니다.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 10, mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('상품 목록 로드 오류: $e')),
      ),
    );
  }
}