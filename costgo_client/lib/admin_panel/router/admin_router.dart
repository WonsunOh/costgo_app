import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:costgo_app/admin_panel/admin_main_screen.dart';

// 관리자용 GoRouter를 제공하는 Provider
final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 관리자 패널의 기본 경로는 AdminMainScreen 입니다.
      GoRoute(
        path: '/',
        builder: (context, state) => const AdminMainScreen(),
      ),
      // TODO: 필요 시 관리자 패널의 다른 경로들을 여기에 추가합니다.
    ],
    // 관리자용 앱은 현재 별도의 리다이렉션 로직이 필요 없으므로 비워둡니다.
    redirect: (context, state) {
      return null;
    },
  );
});