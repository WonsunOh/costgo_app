import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../admin_panel/products/models/admin_product_model.dart';
import '../../providers/wishlist_provider.dart';

// 이 위젯은 이제 AdminProduct 모델을 직접 사용합니다.
class ProductCard extends ConsumerWidget {
  final AdminProduct product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 찜하기 상태는 Node.js와 연동된 wishlistProvider를 통해 가져옵니다.
    final isWishlisted = ref.watch(isProductWishlistedProvider(product.id));

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias, // 이미지가 Card 경계를 넘지 않도록
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: [
                // 상품 이미지
                SizedBox(
                  height: 150, // 높이를 지정하여 레이아웃 안정성 확보
                  width: double.infinity,
                  child: (product.imageUrl.isNotEmpty)
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40)),
                          loadingBuilder: (c, child, progress) => progress == null
                              ? child
                              : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                ),
                // 찜하기 버튼
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.white,
                        shadows: const [Shadow(color: Colors.black38, blurRadius: 4.0)],
                      ),
                      onPressed: () {
                        ref.read(wishlistProvider.notifier).toggleWishlist(product.id, context);
                      },
                    ),
                  ),
                ),
              ],
            ),
            // 상품 정보
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberFormat('#,###').format(product.price)}원',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}