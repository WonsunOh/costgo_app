import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CostGo에 오신 것을 환영합니다!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('최고의 상품을 최저가에 만나보세요.'),
            const SizedBox(height: 40),
            ElevatedButton(
              child: const Text('시작하기'),
              onPressed: () {
                // OnboardingNotifier의 상태를 true로 변경하는 메소드만 호출합니다.
                // 화면 이동은 GoRouter가 상태 변화를 감지하여 자동으로 처리합니다.
                ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
              },
            ),
          ],
        ),
      ),
    );
  }
}