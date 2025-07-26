import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/wishlist_provider.dart';
import 'package:costgo_app/features/product/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistAsync = ref.watch(wishlistItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 상품'),
      ),
      body: wishlistAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text('찜한 상품이 없습니다.'),
            );
          }
          return GridView.builder(
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류: $err')),
      ),
    );
  }
}