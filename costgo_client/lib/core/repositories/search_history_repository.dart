import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/core/providers/shared_preferences_provider.dart';

// RepositoryProvider를 FutureProvider로 변경합니다.
// 이제 SharedPreferences가 준비된 후에 SearchHistoryRepository 인스턴스를 생성합니다.
final searchHistoryRepositoryProvider = FutureProvider<SearchHistoryRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SearchHistoryRepository(prefs);
});

class SearchHistoryRepository {
  final SharedPreferences _prefs;
  static const _historyKey = 'search_history';

  // 생성자에서 SharedPreferences를 필수로 받도록 변경합니다. (null을 허용하지 않음)
  SearchHistoryRepository(this._prefs);

  Future<List<String>> getSearchHistory() async {
    return _prefs.getStringList(_historyKey) ?? [];
  }

  // addSearchTerm이 수정된 리스트를 반환하도록 변경합니다.
  Future<List<String>> addSearchTerm(String term) async {
    final history = _prefs.getStringList(_historyKey) ?? [];
    // 중복 제거 후 가장 앞에 추가
    history.remove(term);
    history.insert(0, term);
    // 최대 10개까지만 저장
    if (history.length > 10) {
      history.removeLast();
    }
    await _prefs.setStringList(_historyKey, history);
    return history;
  }

  Future<List<String>> removeSearchTerm(String term) async {
    final history = _prefs.getStringList(_historyKey) ?? [];
    history.remove(term);
    await _prefs.setStringList(_historyKey, history);
    return history;
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(_historyKey);
  }
}