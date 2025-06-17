import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin_panel/products/providers/admin_product_providers.dart';
import '../../providers/wishlist_provider.dart';
import '../product/product_card.dart';
import '../product_detail/product_detail_screen.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 찜한 상품 목록 Provider를 watch
    final asyncWishlistedIds = ref.watch(wishlistProvider);
    final asyncAllProducts = ref.watch(productAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 상품'),
        centerTitle: true,
      ),
      body: asyncWishlistedIds.when(
        data: (wishlistedIds) {
          return asyncAllProducts.when(
            data: (allProducts) {
              if (wishlistedIds.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('찜한 상품이 없습니다.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
                );
              }

              // ★★★ 찜한 ID에 해당하는 AdminProduct 객체들 필터링 ★★★
              final wishlistedProducts = allProducts
                  .where((product) => wishlistedIds.contains(product.id))
                  .toList();
              
              if (wishlistedProducts.isEmpty) {
                 return const Center(child: Text('찜한 상품 정보를 불러오는 중입니다...'));
              }
              
              // 이제 wishlistedProducts는 List<AdminProduct> 타입입니다.
              return GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: wishlistedProducts.length,
                itemBuilder: (context, index) {
                  // 여기서 product는 이제 AdminProduct 객체입니다.
                  final product = wishlistedProducts[index]; 
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: product)),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('전체 상품 목록 로드 오류: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('찜 목록 로드 오류: $err')),
      ),
    );
  }
}