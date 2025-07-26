import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/core/repositories/user_repository.dart';
import '../models/cart_item_model.dart';
import 'auth_provider.dart';

// CartNotifier를 제공하는 StateNotifierProvider
final cartNotifierProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier(ref);
});

// 장바구니 총액을 계산하는 Provider
final cartTotalProvider = Provider<double>((ref) {
  final cartItems = ref.watch(cartNotifierProvider);
  double total = 0;
  for (final item in cartItems) {
    total += item.product.price * item.quantity;
  }
  return total;
});

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  final Ref _ref;

  CartNotifier(this._ref) : super([]) {
    // authState가 변경될 때마다(로그인/로그아웃) 장바구니 상태를 갱신
    _ref.listen(authNotifierProvider, (previous, next) {
      if (next is Authenticated) {
        state = next.user.cart;
      } else {
        state = [];
      }
    }, fireImmediately: true);
  }

  Future<void> _updateCartOnServer(Future<void> Function() action) async {
    try {
      await action();
      // 성공 시, 서버로부터 최신 사용자 정보를 다시 가져와 앱 전체 상태를 갱신
      await _ref.read(authNotifierProvider.notifier).checkAuthState();
    } catch (e) {
      // 에러 처리 (예: SnackBar 표시)
      print('Cart operation failed: $e');
      // 여기에 사용자에게 에러를 알리는 UI 로직 추가 가능
    }
  }

  void addToCart(String productId) {
    _updateCartOnServer(() => _ref.read(userRepositoryProvider).addToCart(productId));
  }

  void removeFromCart(String productId) {
    _updateCartOnServer(() => _ref.read(userRepositoryProvider).removeFromCart(productId));
  }

  void updateQuantity(String productId, int quantity) {
    _updateCartOnServer(() => _ref.read(userRepositoryProvider).updateCartQuantity(productId, quantity));
  }
}