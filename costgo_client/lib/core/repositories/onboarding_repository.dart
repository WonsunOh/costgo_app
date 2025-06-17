import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/shared_preferences_provider.dart'; 

const String _onboardingCompleteKey = 'onboarding_complete';

// OnboardingRepository Provider
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData?.value; // SharedPreferences 인스턴스를 동기적으로 사용하기 위해 .asData.value 사용
  if (sharedPreferences == null) {
    // SharedPreferences가 아직 로드되지 않았을 경우 예외 처리 또는 기본값 반환
    // 여기서는 간단히 예외를 던지지만, 실제 앱에서는 로딩 상태를 관리해야 할 수 있습니다.
    throw Exception("SharedPreferences not available");
  }
  return OnboardingRepository(sharedPreferences);
});

// Onboarding 완료 상태를 비동기적으로 제공하는 FutureProvider
final onboardingStatusProvider = FutureProvider<bool>((ref) async {
  final onboardingRepository = ref.watch(onboardingRepositoryProvider);
  return await onboardingRepository.isOnboardingComplete();
});


class OnboardingRepository {
  final SharedPreferences _prefs;

  OnboardingRepository(this._prefs);

  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
  }
}