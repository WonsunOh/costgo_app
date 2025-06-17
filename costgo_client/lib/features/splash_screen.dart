import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/shared_preferences_provider.dart';
import '../core/repositories/onboarding_repository.dart';
import '../providers/auth_provider.dart';
import 'auth/additional_info_screen.dart';
import 'auth/login_screen.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart);
    _animationController.forward();
    
    // 위젯의 첫 프레임이 렌더링된 후 초기 화면 결정 로직 실행
    WidgetsBinding.instance.addPostFrameCallback((_) => _determineInitialScreen());
  }

  Future<void> _determineInitialScreen() async {
    // 스플래시 화면 최소 표시 시간 보장
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // 1. 온보딩 완료 여부 확인
      await ref.read(sharedPreferencesProvider.future);
      final isOnboardingComplete = await ref.read(onboardingStatusProvider.future);
      if (!mounted) return;

      if (!isOnboardingComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
        return;
      }
      
      // 2. 자동 로그인 시도 및 Provider 상태 초기화
      await ref.read(authProvider.notifier).checkInitialAuthStatus();
      if (!mounted) return;
      
      // 3. Provider에 저장된 최종 상태를 읽어와서 화면 분기
      final userProfile = ref.read(authProvider).valueOrNull;

      if (userProfile != null) {
        // 로그인된 사용자
        // 4. 추가 정보 입력 여부 확인
        if (userProfile.additionalInfoCompleted) {
          // 모든 정보가 완료된 사용자 -> 메인 화면으로
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          // 추가 정보 입력이 필요한 사용자 -> 추가 정보 입력 화면으로 user 객체 전달
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AdditionalInfoScreen(user: userProfile,)),
          );
        }
      } else {
        // 로그아웃 상태 -> 로그인 화면으로
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e, s) {
      print("SplashScreen에서 초기 화면 결정 중 오류: $e\n$s");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(Icons.shopping_bag, size: 120.0, color: Colors.white),
              ),
              const SizedBox(height: 24.0),
              ScaleTransition(
                scale: _scaleAnimation,
                child: const Text(
                  'E-Commerce App',
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 48.0),
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}