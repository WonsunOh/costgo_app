import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/cart_provider.dart';

import '../../../models/cart_item_model.dart';

class CartItem extends ConsumerWidget {
  final CartItemModel item;

  const CartItem({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // 상품 이미지
            SizedBox(
              width: 80,
              height: 80,
              child: Icon(Icons.image, size: 50, color: Colors.grey[300]),
            ),
            const SizedBox(width: 10),
            // 상품 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${item.product.price.toStringAsFixed(0)}원'),
                ],
              ),
            ),
            // 수량 조절
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (item.quantity > 1) {
                      ref.read(cartNotifierProvider.notifier).updateQuantity(item.product.id, item.quantity - 1);
                    } else {
                      // 수량이 1일 때 누르면 삭제
                      ref.read(cartNotifierProvider.notifier).removeFromCart(item.product.id);
                    }
                  },
                ),
                Text(item.quantity.toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                     ref.read(cartNotifierProvider.notifier).updateQuantity(item.product.id, item.quantity + 1);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}