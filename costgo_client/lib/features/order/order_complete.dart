import 'package:flutter/material.dart';

class OrderCompleteScreen extends StatelessWidget {
  final String orderNumber; // 예시로 주문번호를 받을 수 있음

  const OrderCompleteScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문 완료'),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 숨김
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor, size: 100),
              const SizedBox(height: 24),
              const Text('주문이 성공적으로 완료되었습니다!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('주문번호: $orderNumber', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // 홈 화면으로 이동 (모든 이전 화면 스택 제거)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('쇼핑 계속하기', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}