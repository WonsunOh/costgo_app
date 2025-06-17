import 'package:costgo_app/admin_panel/products/product_list_screen_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'categories/catrgory_management_screen_admin.dart';
import 'users/admin_user_screen.dart';
// 관리자 패널의 각 화면들을 import

// 현재 선택된 메뉴 인덱스를 관리하는 Provider
final adminSelectedPageIndexProvider = StateProvider<int>((ref) => 0);

class AdminMainScreen extends ConsumerWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(adminSelectedPageIndexProvider);

    // 각 메뉴 인덱스에 해당하는 화면 위젯 리스트
    final List<Widget> adminScreens = [
      const AdminDashboardScreen(), // 0: 대시보드 (Placeholder)
      const ProductListScreenAdmin(), // 1: 상품 관리
      const CategoryManagementScreenAdmin(), // 2: 카테고리 관리
      const AdminOrderScreen(),       // 3: 주문 관리 (Placeholder)
      const AdminUserScreen(),        // 4: 회원 관리 (Placeholder)
    ];

    return Scaffold(
      body: Row(
        children: <Widget>[
          // 좌측 네비게이션 레일 (메뉴)
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              ref.read(adminSelectedPageIndexProvider.notifier).state = index;
            },
            labelType: NavigationRailLabelType.selected, // 선택된 항목만 레이블 표시
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('대시보드'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: Text('상품 관리'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category),
                label: Text('카테고리'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: Text('주문 관리'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_alt_outlined),
                selectedIcon: Icon(Icons.people_alt),
                label: Text('회원 관리'),
              ),
            ],
            // TODO: 로그아웃 버튼 추가 가능
            // trailing: Expanded(
            //   child: Align(
            //     alignment: Alignment.bottomCenter,
            //     child: Padding(
            //       padding: const EdgeInsets.only(bottom: 8.0),
            //       child: IconButton(
            //         icon: const Icon(Icons.logout),
            //         onPressed: () {
            //           // TODO: 관리자 로그아웃 로직
            //         },
            //       ),
            //     ),
            //   ),
            // ),
          ),
          const VerticalDivider(thickness: 1, width: 1), // 메뉴와 콘텐츠 구분선
          // 선택된 메뉴에 따라 표시될 메인 콘텐츠 영역
          Expanded(
            child: adminScreens[selectedIndex],
          ),
        ],
      ),
    );
  }
}


// --- 관리자 패널용 임시 Placeholder 화면들 ---

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null, // AppBar는 AdminMainScreen에서 관리하거나, 각 화면이 가질 수 있음
      body: Center(
        child: Text('관리자 대시보드 (통계 등)', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class AdminOrderScreen extends StatelessWidget {
  const AdminOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(
        child: Text('주문 관리 화면', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
