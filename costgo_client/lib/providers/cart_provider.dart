import 'package:costgo_app/admin_panel/products/models/admin_product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item_model.dart';

// 장바구니 상태를 나타내는 클래스 (선택 사항이지만, 총액 등을 관리하기 편함)
class CartState {
  final List<CartItem> items;

  CartState({this.items = const []});

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  int get selectedItemsCount => items.where((item) => item.isSelected).fold(0, (sum, item) => sum + item.quantity);
  double get selectedItemsTotalPrice {
    return items
        .where((item) => item.isSelected)
        .fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  CartState copyWith({
    List<CartItem>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }
}


class CartNotifier extends StateNotifier<CartState> {
  // CartNotifier() : super(CartState(items: _initialCartItems())); // 기존 초기화
  CartNotifier() : super(CartState()) { // 빈 장바구니로 시작하도록 변경 (또는 _initialCartItems 수정)
    // 테스트를 위해 초기 아이템을 추가하고 싶다면 여기서 addItem 호출
    // 예: _initialCartItems().forEach((item) => addItem(item.product, quantity: item.quantity, selectedOptions: item.selectedOptionsDescription));
  }


  // // 임시 초기 장바구니 데이터 (테스트용)
  // static List<CartItem> _initialCartItems() {
  //   return [
  //     CartItem(
  //       product: Product(id: 'prod_cart_1', name: '장바구니 테스트 상품 1 (옵션: 레드, M)', imageUrl: 'https://picsum.photos/seed/cart1/200/200', price: 25000),
  //       quantity: 1,
  //     ),
  //     CartItem(
  //       product: Product(id: 'prod_cart_2', name: '프리미엄 스니커즈 (화이트)', imageUrl: 'https://picsum.photos/seed/cart2/200/200', price: 120000),
  //       quantity: 1,
  //       isSelected: false,
  //     ),
  //     CartItem(
  //       product: Product(id: 'prod_cart_3', name: '유기농 블루베리 500g', imageUrl: 'https://picsum.photos/seed/cart3/200/200', price: 15000),
  //       quantity: 2,
  //     ),
  //   ];
  // }


  // addItem 메소드 수정
  void addItem(AdminProduct product, {int quantity = 1, String? selectedOptions}) {
    final currentState = state;
    final List<CartItem> updatedItems = List.from(currentState.items);
    
    // 고유 ID 생성 (상품 ID + 옵션)
    final newItemUniqueId = '${product.id}_${selectedOptions ?? ""}';

    final itemIndex = updatedItems.indexWhere((item) => item.uniqueId == newItemUniqueId);

    if (itemIndex != -1) {
      // 이미 있는 상품(옵션 동일)이면 수량 증가
      final existingItem = updatedItems[itemIndex];
      updatedItems[itemIndex] = existingItem.copyWith(quantity: existingItem.quantity + quantity);
    } else {
      // 없는 상품(또는 옵션 다름)이면 새로 추가
      updatedItems.add(CartItem(
        product: product,
        quantity: quantity,
        selectedOptionsDescription: selectedOptions,
      ));
    }
    state = currentState.copyWith(items: updatedItems);
  }

  // removeItem, updateQuantity, toggleItemSelected 등도 uniqueId 기준으로 동작하도록 수정 필요
  // (간결성을 위해 여기서는 addItem만 수정하고, 나머지는 productId만으로 동작한다고 가정.
  //  실제로는 uniqueId를 사용하도록 모두 수정하는 것이 좋습니다.)

  // removeItem 예시 (uniqueId 사용)
  void removeItemByUniqueId(String uniqueId) {
    final currentState = state;
    final updatedItems = currentState.items.where((item) => item.uniqueId != uniqueId).toList();
    state = currentState.copyWith(items: updatedItems);
  }

  // updateQuantity 예시 (uniqueId 사용)
  void updateQuantityByUniqueId(String uniqueId, int newQuantity) {
     if (newQuantity <= 0) {
      removeItemByUniqueId(uniqueId);
      return;
    }
    final currentState = state;
    final updatedItems = currentState.items.map((item) {
      if (item.uniqueId == uniqueId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
    state = currentState.copyWith(items: updatedItems);
  }
  
  // toggleItemSelected 예시 (uniqueId 사용)
  void toggleItemSelectedByUniqueId(String uniqueId) {
    final currentState = state;
    final updatedItems = currentState.items.map((item) {
      if (item.uniqueId == uniqueId) {
        return item.copyWith(isSelected: !item.isSelected);
      }
      return item;
    }).toList();
    state = currentState.copyWith(items: updatedItems);
  }

  // 기존 removeItem, updateQuantity, toggleItemSelected는 productId만 사용하므로,
  // CartItemWidget 등에서 호출 시 uniqueId를 사용하도록 수정하거나,
  // CartNotifier 내에서 productId로 해당 상품의 모든 옵션을 다루는 로직을 추가해야 합니다.
  // 여기서는 간단히 uniqueId를 사용하는 새 메소드를 추가하고, CartItemWidget에서 이를 호출하도록 변경합니다.

  // ... (toggleAllItemsSelected, clearCart는 기존과 유사하게 유지 가능)
  void toggleAllItemsSelected(bool selectAll) {
    final currentState = state;
    final updatedItems = currentState.items.map((item) => item.copyWith(isSelected: selectAll)).toList();
    state = currentState.copyWith(items: updatedItems);
  }

  void clearCart() {
    state = CartState(items: []);
  }
}

// CartNotifier Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// 선택된 상품들의 총 가격을 계산하는 Provider (Selector와 유사)
final selectedItemsTotalPriceProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.selectedItemsTotalPrice;
});

// 선택된 상품들의 총 개수를 계산하는 Provider
final selectedItemsCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.selectedItemsCount;
});

// 장바구니에 담긴 전체 아이템(Product 기준) 개수를 나타내는 Provider (뱃지용)
final cartItemCountProvider = Provider<int>((ref) {
  final cartItems = ref.watch(cartProvider).items;
  return cartItems.length; // 상품 종류 수
  // return cartItems.fold(0, (sum, item) => sum + item.quantity); // 총 상품 수량
});