import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/core/repositories/wishlist_repository.dart';
import 'package:costgo_app/models/product_model.dart';

// 위시리스트에 담긴 상품들의 상세 정보를 제공하는 Provider
final wishlistItemsProvider = FutureProvider<List<ProductModel>>((ref) {
  // 인증 상태가 변경되면 이 Provider도 자동으로 재실행됩니다.
  return ref.watch(wishlistRepositoryProvider).getWishlist();
});

// 위시리스트에 담긴 상품들의 ID만 Set으로 관리하는 Provider
// (상품 카드 등에서 '찜' 여부를 빠르게 확인하기 위함)
final wishlistNotifierProvider = StateNotifierProvider<WishlistNotifier, Set<String>>((ref) {
  return WishlistNotifier(ref);
});

class WishlistNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;

  WishlistNotifier(this._ref) : super({});

  // 위시리스트 초기화
  Future<void> initialize() async {
    final wishlistItems = await _ref.read(wishlistRepositoryProvider).getWishlist();
    state = wishlistItems.map((item) => item.id).toSet();
  }

  Future<void> add(String productId) async {
    await _ref.read(wishlistRepositoryProvider).addToWishlist(productId);
    state = {...state, productId};
    _ref.invalidate(wishlistItemsProvider); // 상세 목록도 새로고침
  }

  Future<void> remove(String productId) async {
    await _ref.read(wishlistRepositoryProvider).removeFromWishlist(productId);
    state = state.where((id) => id != productId).toSet();
    _ref.invalidate(wishlistItemsProvider); // 상세 목록도 새로고침
  }

  void clear() {
    state = {};
  }
}