import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/models/product_model.dart';
import 'package:costgo_app/core/repositories/product_repository.dart';
import 'package:costgo_app/core/repositories/search_history_repository.dart';

// 1. 현재 검색어를 관리하는 Provider (변경 없음)
final searchQueryProvider = StateProvider<String>((ref) => '');

// 2. 검색 결과를 비동기적으로 가져오는 Provider (변경 없음)
final searchResultsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 2) {
    return [];
  }
  return ref.watch(productRepositoryProvider).searchProducts(query);
});

// 3. 최근 검색어 목록을 관리하는 Provider 수정
final searchHistoryNotifierProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier(ref);
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  final Ref _ref;

  SearchHistoryNotifier(this._ref) : super([]) {
    // Repository가 준비되면 즉시 기록을 로드
    _ref.read(searchHistoryRepositoryProvider.future).then((repo) {
      _loadHistory(repo);
    });
  }

  void _loadHistory(SearchHistoryRepository repository) async {
    state = await repository.getSearchHistory();
  }

  void addTerm(String term) async {
    // Repository가 준비될 때까지 기다립니다.
    final repository = await _ref.read(searchHistoryRepositoryProvider.future);
    // repository의 addSearchTerm이 반환하는 최신 리스트를 state에 할당합니다.
    state = await repository.addSearchTerm(term);
  }

  void removeTerm(String term) async {
    final repository = await _ref.read(searchHistoryRepositoryProvider.future);
    state = await repository.removeSearchTerm(term);
  }

  void clearHistory() async {
    final repository = await _ref.read(searchHistoryRepositoryProvider.future);
    await repository.clearSearchHistory();
    state = [];
  }
}