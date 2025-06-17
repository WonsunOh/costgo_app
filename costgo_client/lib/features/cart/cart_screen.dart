import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/cart_item_model.dart';
import '../../providers/cart_provider.dart';
import '../order/order_form_screen.dart';
import 'widgets/cart_item.dart';

class ShoppingCartScreen extends ConsumerWidget {
  const ShoppingCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cartItems = cartState.items;
    final selectedItemsTotalPrice = ref.watch(selectedItemsTotalPriceProvider);
    final selectedItemsCount = ref.watch(selectedItemsCountProvider);

    final bool isAllSelected = cartItems.isNotEmpty && cartItems.every((item) => item.isSelected);

    return Scaffold(
      appBar: AppBar(
        title: const Text('장바구니'),
        centerTitle: true,
        elevation: 1,
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).toggleAllItemsSelected(!isAllSelected);
              },
              child: Text(
                isAllSelected ? '전체해제' : '전체선택',
                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCartView(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems[index];
                      return CartItemWidget(cartItem: cartItem);
                    },
                  ),
                ),
                // 하단 주문 요약 및 버튼
                _buildOrderSummarySection(context, selectedItemsCount, selectedItemsTotalPrice, ref),
              ],
            ),
    );
  }

  Widget _buildEmptyCartView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text(
            '장바구니가 비어있습니다.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // 홈 화면으로 이동 (모든 이전 화면 스택 제거 후 홈으로)
              // 또는 MainScreen의 탭을 0번(홈)으로 변경
              Navigator.of(context).popUntil((route) => route.isFirst);
              // 만약 MainScreen의 탭을 Riverpod으로 관리한다면:
              // ref.read(mainScreenTabProvider.notifier).state = 0;
              // Navigator.of(context).pop(); // 현재 장바구니 화면 닫기
              print('쇼핑 계속하기 -> 홈으로 이동');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            child: const Text('쇼핑 계속하기', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(BuildContext context, int selectedCount, double totalPrice, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.5),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 선택된 상품: $selectedCount개',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)}원',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: selectedCount > 0
                ? () {
                    // 주문할 상품 목록 필터링
                    final List<CartItem> itemsToOrder = ref.read(cartProvider).items.where((item) => item.isSelected).toList();
                    
                    if (itemsToOrder.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('주문할 상품을 선택해주세요.')),
                      );
                      return;
                    }

                    print('선택된 상품 ${itemsToOrder.length}개 주문하기');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderFormScreen(orderedItems: itemsToOrder),
                      ),
                    );
                  }
                : null, // 선택된 상품이 없으면 비활성화
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor, // 활성화 상태 배경색
              foregroundColor: Colors.white, // 활성화 상태 텍스트 및 아이콘 색상
              disabledBackgroundColor: Colors.grey.shade300, // 비활성화 상태 배경색
              disabledForegroundColor: Colors.grey.shade500, // 비활성화 상태 텍스트 및 아이콘 색상
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 여기에는 color를 지정하지 않는 것이 좋음
            ),
            child: Text('주문하기 (${selectedCount}개)', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}