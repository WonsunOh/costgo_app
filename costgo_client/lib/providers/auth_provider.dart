import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'wishlist_provider.dart';

// 1. AuthState 정의 (sealed class 사용)
sealed class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}


// 2. AuthNotifier 를 AsyncNotifier 로 변경 고려 또는 StateNotifier 유지
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  late final AuthRepository _authRepository;

  AuthNotifier(this._ref) : super(AuthInitial()) {
    _authRepository = _ref.read(authRepositoryProvider);
    checkAuthState();
  }

  // 사용자 세션을 초기화하는 공통 로직
  Future<void> _initializeUserSession(UserModel user) async {
    state = Authenticated(user);
    // 로그인/회원가입 성공 직후, 위시리스트 상태를 초기화합니다.
    await _ref.read(wishlistNotifierProvider.notifier).initialize();
  }

  Future<void> checkAuthState() async {
    state = AuthLoading();
    try {
      final user = await _authRepository.getUserData();
      if (user != null) {
        await _initializeUserSession(user);
      } else {
        state = Unauthenticated();
      }
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _authRepository.login(email, password);
      await _initializeUserSession(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> signUp(String username, String email, String password) async {
    state = AuthLoading();
    try {
      final user = await _authRepository.signUp(username, email, password);
      await _initializeUserSession(user);
    } catch (e) {
      state = AuthError(e.toString());
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _ref.read(wishlistNotifierProvider.notifier).clear(); // 로그아웃 시 위시리스트 비우기
    state = Unauthenticated();
  }

}