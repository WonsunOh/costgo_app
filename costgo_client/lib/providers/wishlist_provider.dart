import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/repositories/wishlist_repository.dart';
import 'auth_provider.dart';


// ★★★ Notifier의 상태 타입을 AsyncValue<List<String>>으로 명시 ★★★
class WishlistNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final WishlistRepository _repository;
  final bool _isLoggedIn;

  WishlistNotifier(this._repository, this._isLoggedIn)
      : super(const AsyncValue.loading()) {
    if (_isLoggedIn) {
      fetchWishlist();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  // 찜 목록(상품 ID 리스트) 가져오기
  Future<void> fetchWishlist() async {
    if (!_isLoggedIn) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      // Repository는 이제 상품 ID의 리스트를 반환해야 함
      final wishlistIds = await _repository.fetchWishlistIds();
      state = AsyncValue.data(wishlistIds);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // 찜하기 상태 토글
  Future<void> toggleWishlist(String productId, BuildContext contextForSnackbar) async {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(contextForSnackbar).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final currentAsyncState = state;
    // .valueOrNull은 데이터가 없거나 로딩/에러 시 null을 반환
    final currentWishlistIds = currentAsyncState.valueOrNull ?? [];
    final isWishlisted = currentWishlistIds.contains(productId);

    // 낙관적 업데이트: UI를 먼저 변경
    final updatedList = List<String>.from(currentWishlistIds);
    if (isWishlisted) {
      updatedList.remove(productId);
    } else {
      updatedList.add(productId);
    }
    state = AsyncValue.data(updatedList);

    try {
      // API 호출
      if (isWishlisted) {
        await _repository.removeFromWishlist(productId);
      } else {
        await _repository.addToWishlist(productId);
      }
      // 성공 시에는 이미 UI가 업데이트되었으므로 추가 작업 불필요.
      // 만약 서버와 100% 동기화를 원한다면 아래 주석 해제
      // await fetchWishlist();
    } catch (e) {
      // API 호출 실패 시, UI를 이전 상태로 롤백
      ScaffoldMessenger.of(contextForSnackbar).showSnackBar(
        SnackBar(content: Text('찜하기 처리 중 오류: ${e.toString()}')),
      );
      state = currentAsyncState; // 저장해둔 이전 상태로 복원
    }
  }
}

// ★★★ StateNotifierProvider 정의 수정 ★★★
final wishlistProvider =
    StateNotifierProvider.autoDispose<WishlistNotifier, AsyncValue<List<String>>>((ref) {
  final isLoggedIn = ref.watch(authProvider).valueOrNull != null;
  return WishlistNotifier(ref.watch(wishlistRepositoryProvider), isLoggedIn);
});

// isProductWishlistedProvider는 변경할 필요 없음
final isProductWishlistedProvider = Provider.autoDispose.family<bool, String>((ref, productId) {
  final wishlistAsyncValue = ref.watch(wishlistProvider);
  return wishlistAsyncValue.maybeWhen(
    data: (wishlistedIds) => wishlistedIds.contains(productId),
    orElse: () => false,
  );
});