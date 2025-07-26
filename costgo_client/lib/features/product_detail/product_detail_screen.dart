import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/product_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // productDetailProvider에 productId를 전달하여 특정 상품 정보를 가져옵니다.
    final productAsync = ref.watch(productDetailProvider(productId));

    return Scaffold(
      body: productAsync.when(
        data: (product) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(product.name, style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 2.0)])),
                background: Hero(
                  tag: 'product_image_${product.id}',
                  child: product.images.isNotEmpty
                      ? Image.network(
                          product.images.first,
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${product.price.toStringAsFixed(0)}원',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '카테고리: ${product.category?.name ?? '미지정'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      '상품 설명',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('상품 정보를 불러오지 못했습니다: $err')),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            // TODO: 장바구니에 담기 로직 구현
          },
          child: const Text('장바구니에 담기'),
        ),
      ),
    );
  }
}