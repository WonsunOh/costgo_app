import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderCompleteScreen extends StatelessWidget {
  const OrderCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            Text(
              '주문이 완료되었습니다!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // 홈 화면으로 이동 (뒤로가기 스택 모두 제거)
                context.go('/');
              },
              child: const Text('쇼핑 계속하기'),
            ),
            TextButton(
              onPressed: () {
                // 주문 내역 화면으로 이동 (뒤로가기 스택 모두 제거)
                context.go('/profile/orders'); // 이 경로는 router.dart에 정의해야 합니다.
              },
              child: const Text('주문 내역 확인하기'),
            )
          ],
        ),
      ),
    );
  }
}