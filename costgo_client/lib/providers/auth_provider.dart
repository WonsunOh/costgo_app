import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/repositories/auth_repository.dart';
import '../models/user_model.dart';

// 인증 상태를 관리하는 Notifier (AsyncValue<UserModel?>)
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _authRepository;
  
  // 생성 시에는 초기 로딩 상태로만 설정
  AuthNotifier(this._authRepository) : super(const AsyncValue.loading());

  // ★★★ 상태를 직접 업데이트하는 메소드 추가 ★★★
  void setUser(UserModel user) {
    // API를 다시 호출하지 않고, 전달받은 user 객체로 즉시 상태를 업데이트합니다.
    state = AsyncValue.data(user);
  }

  // 앱 시작 시 저장된 토큰으로 자동 로그인 시도
  Future<UserModel?> checkInitialAuthStatus() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.tryAutoLogin();
      state = AsyncValue.data(user);
      return user;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return null;
    }
  }

  // 이메일/비밀번호 로그인
   Future<UserModel> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.signIn(email: email, password: password);
      state = AsyncValue.data(user);
      return user;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow;
    }
  }

  // ★★★ signInWithGoogle 메소드 추가 ★★★
  Future<UserModel?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      // AuthRepository의 Google 로그인 메소드 호출
      final user = await _authRepository.signInWithGoogle();
      // Notifier의 상태를 새로운 사용자 정보로 업데이트
      state = AsyncValue.data(user);
      // 로그인된 사용자 정보 반환
      return user;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      rethrow; // UI에서 에러를 처리할 수 있도록 다시 던짐
    }
  }


  // 로그아웃
  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AsyncValue.data(null); // 상태를 로그아웃(null)으로 변경
  }
}

// 앱 전체에서 인증 상태를 참조하기 위한 StateNotifierProvider
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});