import 'package:flutter/material.dart';
import 'package:costgo_app/models/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/wishlist_provider.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 위시리스트 상태를 watch
    final wishlistIds = ref.watch(wishlistNotifierProvider);
    final isWishlisted = wishlistIds.contains(product.id);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // GoRouter를 사용하여 상품 상세 페이지로 이동
          context.push('/product/${product.id}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                onTap: () => context.push('/product/${product.id}'),
                child: Hero(
                  // Hero 애니메이션을 위한 고유 태그
                  tag: 'product_image_${product.id}',
                  child: Container(
                    color: Colors.grey[200],
                    child: product.images.isNotEmpty
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : const Center(
                            child: Icon(Icons.image, size: 80, color: Colors.grey),
                          ),
                  ),
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
            Positioned(
          top: 4,
          right: 4,
          child: IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.grey,
            ),
            onPressed: () {
                final notifier = ref.read(wishlistNotifierProvider.notifier);
                if (isWishlisted) {
                  notifier.remove(product.id);
                } else {
                  notifier.add(product.id);
                }
              },
          ),
        ),
          ],
        ),
        
      ),
    );
  }
}