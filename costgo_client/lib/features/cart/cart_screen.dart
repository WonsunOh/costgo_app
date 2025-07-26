import 'package:costgo_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/cart_provider.dart';
import 'package:costgo_app/utils/kr_price_format.dart';
import '../../models/cart_item_model.dart';
import 'widgets/cart_item.dart';
import 'package:go_router/go_router.dart'; // GoRouter 임포트 추가

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartNotifierProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니 (${cartItems.length})'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text('장바구니에 담긴 상품이 없습니다.'),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return CartItem(item: cartItems[index]);
                    },
                  ),
                ),
                // 주문 정보 및 결제 버튼
                // 1. _buildCheckoutSection 호출 시 cartItems를 전달합니다.
                _buildCheckoutSection(context, cartItems, cartTotal),
              ],
            ),
    );
  }

  // 2. _buildCheckoutSection 메소드 정의에서 cartItems를 인자로 받습니다.
  Widget _buildCheckoutSection(BuildContext context, List<CartItemModel> cartItems, double total) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('총 상품 금액:', style: TextStyle(fontSize: 16)),
                Text(krPriceFormat(total), style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('배송비:', style: TextStyle(fontSize: 16)),
                Text('3,000원', style: TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('총 결제금액:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  krPriceFormat(total + 3000),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              // 3. 이제 cartItems에 접근할 수 있으므로 에러가 발생하지 않습니다.
              onPressed: cartItems.isNotEmpty
                  ? () {
                      context.push('/order-form');
                    }
                  : null,
              child: const Text('주문하기'),
            ),
          ],
        ),
      ),
    );
  }
}