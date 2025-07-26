import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:costgo_app/core/providers/shared_preferences_provider.dart';

// RepositoryProvider는 SharedPreferences가 로딩된 후에 Repository를 생성하도록 FutureProvider로 변경합니다.
final onboardingRepositoryProvider = FutureProvider<OnboardingRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return OnboardingRepository(prefs);
});

class OnboardingRepository {
  final SharedPreferences _prefs;
  static const _onboardingCompleteKey = 'onboarding_complete';

  OnboardingRepository(this._prefs);

  // 동기 메소드로 변경
  bool hasSeenOnboarding() {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
  }
}