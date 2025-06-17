import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/cart_item_model.dart';
import '../../../providers/cart_provider.dart';

class CartItemWidget extends ConsumerWidget {
  final CartItem cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 선택 체크박스
            SizedBox(
              width: 24, // 체크박스 공간 확보
              child: Checkbox(
                value: cartItem.isSelected,
                onChanged: (bool? value) {
                  ref.read(cartProvider.notifier).toggleItemSelectedByUniqueId(cartItem.uniqueId);
                },
                visualDensity: VisualDensity.compact,
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 12),

            // 상품 이미지 (임시)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200,
                child: cartItem.product.imageUrl.startsWith('http')
                    ? Image.network(cartItem.product.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => const Icon(Icons.error_outline, size: 40),
                      )
                    : Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 12),

            // 상품 정보 및 수량 조절
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 옵션 표시 (추가)
                  if (cartItem.selectedOptionsDescription != null && cartItem.selectedOptionsDescription!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '옵션: ${cartItem.selectedOptionsDescription}',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    '${cartItem.product.price.toStringAsFixed(0)}원',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 수량 조절
                      Row(
                        children: [
                          _buildQuantityButton(
                            context,
                            icon: Icons.remove,
                            onPressed: cartItem.quantity > 1
                                ? () {
                                    // uniqueId 사용으로 변경
                                    ref.read(cartProvider.notifier).updateQuantityByUniqueId(cartItem.uniqueId, cartItem.quantity - 1);
                                  }
                                : null, // 1개일 때는 비활성화
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              '${cartItem.quantity}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildQuantityButton(
                            context,
                            icon: Icons.add,
                            onPressed: () {
                              // uniqueId 사용으로 변경
                              ref.read(cartProvider.notifier).updateQuantityByUniqueId(cartItem.uniqueId, cartItem.quantity + 1);
                            },
                          ),
                        ],
                      ),
                      // 삭제 버튼
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                        onPressed: () {
                          // uniqueId 사용으로 변경
                          ref.read(cartProvider.notifier).removeItemByUniqueId(cartItem.uniqueId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${cartItem.product.name} 삭제됨'), duration: const Duration(seconds: 1)),
                          );
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(BuildContext context, {required IconData icon, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: onPressed != null ? Colors.grey.shade400 : Colors.grey.shade300),
          color: onPressed == null ? Colors.grey.shade100 : Colors.transparent,
        ),
        child: Icon(icon, size: 18, color: onPressed != null ? Colors.black87 : Colors.grey.shade400),
      ),
    );
  }
}