import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/core/repositories/onboarding_repository.dart';

// Onboarding 상태를 관리하는 StateNotifierProvider
final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref);
});

class OnboardingNotifier extends StateNotifier<bool> {
  final Ref _ref;
  OnboardingRepository? _repository;

  OnboardingNotifier(this._ref) : super(false) {
    _init();
  }

  // Provider 초기화 시 저장된 온보딩 상태를 불러옵니다.
  Future<void> _init() async {
    // Repository가 준비될 때까지 기다립니다.
    _repository = await _ref.read(onboardingRepositoryProvider.future);
    state = _repository!.hasSeenOnboarding();
  }
  
  // 온보딩을 완료 상태로 변경하고, 이를 저장합니다.
  Future<void> completeOnboarding() async {
    if (_repository == null) {
      _repository = await _ref.read(onboardingRepositoryProvider.future);
    }
    await _repository!.setOnboardingComplete();
    state = true; // 상태를 true로 변경하여 watch하고 있는 모든 곳에 알립니다.
  }
}