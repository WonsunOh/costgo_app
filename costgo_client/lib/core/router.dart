import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:costgo_app/providers/auth_provider.dart';
import 'package:costgo_app/providers/onboarding_provider.dart';

// 모든 화면 import
import 'package:costgo_app/features/splash_screen.dart';
import 'package:costgo_app/features/onboarding_screen.dart';
import 'package:costgo_app/features/auth/login_screen.dart';
import 'package:costgo_app/features/auth/sign_up_screen.dart';
import 'package:costgo_app/features/main_screen.dart';
import 'package:costgo_app/features/product_detail/product_detail_screen.dart';
import 'package:costgo_app/features/profile_menu/edit_profile_screen.dart';
import 'package:costgo_app/features/profile_menu/order_history_screen.dart';
import 'package:costgo_app/features/profile_menu/wishlist_screen.dart';
import 'package:costgo_app/features/order/order_form_screen.dart';
import 'package:costgo_app/features/order/order_complete.dart';

import '../features/auth/additional_info_screen.dart';
// ... 등 필요한 모든 화면 import

final routerProvider = Provider<GoRouter>((ref) {
  // 앱의 핵심 상태들을 watch하여 변경을 감지합니다.
  final authState = ref.watch(authNotifierProvider);
  final onboardingCompleted = ref.watch(onboardingNotifierProvider);

  // 로그인이 꼭 필요한 경로 목록
  final protectedRoutes = [
    '/profile/edit',
    '/profile/wishlist',
    '/profile/orders',
    '/order-form',
    '/cart' // 장바구니도 로그인이 필요하다고 가정
  ];

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
      GoRoute(path: '/additional-info', builder: (context, state) => const AdditionalInfoScreen()),
      GoRoute(path: '/', builder: (context, state) => const MainScreen()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: '/profile/wishlist', builder: (context, state) => const WishlistScreen()),
      GoRoute(path: '/profile/orders', builder: (context, state) => const OrderHistoryScreen()),
      GoRoute(
        path: '/product/:productId',
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(path: '/order-form', builder: (context, state) => const OrderFormScreen()),
      GoRoute(path: '/order-complete', builder: (context, state) => const OrderCompleteScreen()),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final location = state.matchedLocation;
      final isAuthReady = authState is! AuthInitial && authState is! AuthLoading;

      if (!isAuthReady) return '/splash';
      if (!onboardingCompleted) return location == '/onboarding' ? null : '/onboarding';

      final isLoggedIn = authState is Authenticated;
      
      // // 로그인 후, 프로필 작성이 완료되지 않았다면 추가 정보 화면으로 보냅니다.
      // if (isLoggedIn && !authState.user.isProfileComplete) {
      //   return location == '/additional-info' ? null : '/additional-info';
      // }

      // final isGoingToAuthScreen = location == '/login' || location == '/signup' || location == '/additional-info';

      // if (!isLoggedIn) return isGoingToAuthScreen || location == '/onboarding' ? null : '/login';
      
      // if (isLoggedIn && (isGoingToAuthScreen || location == '/splash')) {
      //   return '/';
      // }
      
      // 1. 로그인이 필요한 페이지에 접근하려는데, 로그인이 안 되어 있는 경우
      if (protectedRoutes.contains(location) && !isLoggedIn) {
        // 로그인 화면으로 보냅니다.
        return '/login';
      }

      // 2. 로그인 된 사용자가 로그인/회원가입 화면으로 가려는 경우
      if (isLoggedIn && (location == '/login' || location == '/signup')) {
        // 메인 화면으로 보냅니다.
        return '/';
      }
      
      // 3. 그 외 모든 경우는 허용합니다. (리다이렉션 없음)
      return null;
    },
  );
});