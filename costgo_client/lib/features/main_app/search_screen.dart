import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin_panel/products/providers/admin_product_providers.dart';
import '../../core/repositories/search_history_repository.dart';
import '../product/product_card.dart';
import '../product_detail/product_detail_screen.dart';


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  // 임시 인기 검색어 (실제로는 서버에서 받아옴)
  final List<String> _popularKeywords = [
    '여름 원피스', '선크림 추천', '캠핑용품', '나이키 운동화', '노트북 거치대',
    '강아지 간식', '제주도 항공권', '블루투스 이어폰', '밀키트', '오늘의 특가'
  ];

  @override
  void initState() {
    super.initState();
    // TextField의 값이 변경될 때마다 검색어 Provider의 상태를 업데이트
    _searchController.addListener(() {
      ref.read(adminProductSearchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 초기 화면 (최근/인기 검색어) 빌드
  Widget _buildInitialSearchScreen() {
    final searchHistory = ref.watch(searchHistoryProvider);
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (searchHistory.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('최근 검색어', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () async {
                  await ref.read(searchHistoryRepositoryProvider).clearSearchHistory();
                  ref.invalidate(searchHistoryProvider); // StateProvider 강제 새로고침
                },
                child: const Text('전체 삭제', style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: searchHistory.map((term) {
              return ActionChip(
                label: Text(term),
                onPressed: (){
                   _searchController.text = term;
                   ref.read(searchHistoryRepositoryProvider).addSearchTerm(term);
                },
                avatar: const Icon(Icons.history, size: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Colors.grey.shade200,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
        const Text('인기 검색어', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _popularKeywords.length,
          itemBuilder: (context, index) {
            final keyword = _popularKeywords[index];
            return ListTile(
              leading: Text('${index + 1}', style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              title: Text(keyword, style: const TextStyle(fontSize: 15)),
              dense: true,
              onTap: () {
                _searchController.text = keyword;
                ref.read(searchHistoryRepositoryProvider).addSearchTerm(keyword);
              },
            );
          },
        ),
      ],
    );
  }

  // 검색 결과 화면 빌드
  Widget _buildSearchResultsView(String currentQuery) {
    final asyncSearchResults = ref.watch(adminSearchedProductsProvider(currentQuery));
    
    return asyncSearchResults.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Text(
              '"$currentQuery"에 대한 검색 결과가 없습니다.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(12.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () {
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product)),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('검색 중 오류 발생: $err')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSearchQuery = ref.watch(adminProductSearchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '검색어를 입력하세요...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          style: const TextStyle(fontSize: 17),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(searchHistoryRepositoryProvider).addSearchTerm(value.trim());
            }
          },
        ),
        actions: [
          if (currentSearchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () => _searchController.clear(),
            ),
        ],
      ),
      body: currentSearchQuery.trim().isEmpty
          ? _buildInitialSearchScreen()
          : _buildSearchResultsView(currentSearchQuery.trim()),
    );
  }
}