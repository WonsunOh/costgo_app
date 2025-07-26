import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/search_provider.dart';
import 'package:costgo_app/features/product/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchHistory = ref.watch(searchHistoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '상품을 검색해보세요',
            border: InputBorder.none,
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value;
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              ref.read(searchHistoryNotifierProvider.notifier).addTerm(value);
            }
          },
        ),
      ),
      body: searchQuery.length < 2
          ? _buildSearchHistory(searchHistory)
          : _buildSearchResults(),
    );
  }

  Widget _buildSearchHistory(List<String> history) {
    if (history.isEmpty) {
      return const Center(child: Text('최근 검색 기록이 없습니다.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최근 검색어', style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                onPressed: () => ref.read(searchHistoryNotifierProvider.notifier).clearHistory(),
                child: const Text('전체 삭제'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final term = history[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(term),
                onTap: () {
                  _textController.text = term;
                  _textController.selection = TextSelection.fromPosition(TextPosition(offset: term.length));
                  ref.read(searchQueryProvider.notifier).state = term;
                },
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => ref.read(searchHistoryNotifierProvider.notifier).removeTerm(term),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final searchResults = ref.watch(searchResultsProvider);

    return searchResults.when(
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('검색 결과가 없습니다.'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) => ProductCard(product: products[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('검색 중 오류 발생: $err')),
    );
  }
}