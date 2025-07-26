import 'package:flutter/material.dart';

// ConsumerWidget일 필요도 없습니다.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 이 화면은 로딩 인디케이터만 보여주고, 모든 화면 전환 결정은 GoRouter가 합니다.
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('앱을 시작하고 있습니다...'),
          ],
        ),
      ),
    );
  }
}