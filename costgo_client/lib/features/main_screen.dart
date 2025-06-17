import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/main_screen_tab_provider.dart';
import 'main_app/category_screen.dart';
import 'main_app/home_screen.dart';
import 'main_app/profile_screen.dart';
import 'main_app/search_screen.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

 static const List<Widget> _screens = [
    HomeScreen(),
    CategoryScreen(),
    SearchScreen(), // 임시 검색 화면
    ProfileScreen(),
  ];

  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainScreenCurrentTabProvider);
    return Scaffold(
      body: IndexedStack( // 탭 전환 시 화면 상태 유지를 위해 IndexedStack 사용
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(mainScreenCurrentTabProvider.notifier).state = index; // 탭 인덱스 업데이트
        },
        type: BottomNavigationBarType.fixed, // 탭이 4개 이상일 때 아이템 크기 고정 및 레이블 항상 표시
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: '카테고리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}