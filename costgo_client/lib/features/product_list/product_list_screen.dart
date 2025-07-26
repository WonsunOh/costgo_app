import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/product_provider.dart';
import 'package:costgo_app/features/product/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  // 특정 카테고리의 상품 목록을 보여주고 싶다면 이 파라미터를 사용
  final String? categoryId; 
  final String categoryName;

  const ProductListScreen({super.key, this.categoryId, required this.categoryName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: categoryId를 사용하여 필터링하는 로직을 productsProvider에 추가해야 합니다.
    // 지금은 모든 상품을 가져옵니다.
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: productsAsync.when(
        data: (products) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('상품 로딩 실패: $err')),
      ),
    );
  }
}