import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/shared_preferences_provider.dart';

const String _searchHistoryKey = 'search_history';
const int _maxHistoryCount = 10; // 최근 검색어 최대 저장 개수

// SearchHistoryRepository Provider
final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider).asData?.value;
  if (sharedPreferences == null) {
    throw Exception("SharedPreferences not available for SearchHistoryRepository");
  }
  return SearchHistoryRepository(sharedPreferences);
});

// 최근 검색어 목록을 제공하는 StateProvider (UI에서 쉽게 업데이트 가능하도록)
final searchHistoryProvider = StateProvider<List<String>>((ref) {
  final searchHistoryRepository = ref.watch(searchHistoryRepositoryProvider);
  return searchHistoryRepository.getSearchHistory(); // 초기값 로드
});

class SearchHistoryRepository {
  final SharedPreferences _prefs;

  SearchHistoryRepository(this._prefs);

  List<String> getSearchHistory() {
    return _prefs.getStringList(_searchHistoryKey) ?? [];
  }

  Future<void> addSearchTerm(String term) async {
    if (term.trim().isEmpty) return;

    List<String> history = getSearchHistory();
    // 중복 제거 (기존에 있으면 삭제 후 맨 앞에 추가)
    history.removeWhere((item) => item.toLowerCase() == term.toLowerCase().trim());
    history.insert(0, term.trim());

    // 최대 개수 제한
    if (history.length > _maxHistoryCount) {
      history = history.sublist(0, _maxHistoryCount);
    }
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> removeSearchTerm(String term) async {
    List<String> history = getSearchHistory();
    history.removeWhere((item) => item.toLowerCase() == term.toLowerCase().trim());
    await _prefs.setStringList(_searchHistoryKey, history);
  }

  Future<void> clearSearchHistory() async {
    await _prefs.remove(_searchHistoryKey);
  }
}