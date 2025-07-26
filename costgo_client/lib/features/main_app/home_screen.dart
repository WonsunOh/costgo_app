// costgo_client/lib/features/main_app/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/category_provider.dart';
import 'package:costgo_app/providers/product_provider.dart';
// 새로 만든 공용 ProductModel을 임포트합니다.
import 'package:costgo_app/models/product_model.dart'; // 이 줄을 추가하세요.

// HomeScreen의 나머지 코드는 이전 답변과 동일합니다.
// build 메소드 내에서 product.name, product.price 등을 사용하는 부분이
// 에러 없이 동작할 것입니다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CostGo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsProvider);
          ref.invalidate(categoryProvider);
        },
        child: ListView(
          children: [
            _buildSectionTitle(context, '카테고리'),
            categoriesAsync.when(
              data: (categories) => SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    if (category.parentId == null) {
                       return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(label: Text(category.name)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              loading: () => const Center(heightFactor: 3, child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('카테고리 로딩 실패: $err')),
            ),

            _buildSectionTitle(context, '추천 상품'),
            productsAsync.when(
              data: (products) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.image, size: 80, color: Colors.grey),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(bottom: 8.0),
                          child: Text(
                            '${product.price.toStringAsFixed(0)}원',
                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              loading: () => const Center(heightFactor: 5, child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('상품 로딩 실패: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}