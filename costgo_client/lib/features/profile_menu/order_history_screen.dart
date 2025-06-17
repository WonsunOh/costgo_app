import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주문/배송 조회'),
        centerTitle: true,
      ),
      body: ListView.builder( // 실제로는 주문 목록을 표시
        itemCount: 3, // 예시로 3개의 주문
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(Icons.receipt_long_outlined, color: Theme.of(context).primaryColor),
              title: Text('주문번호: ORD2025060${index + 1}'),
              subtitle: Text('주문일: 2025-05-${28 + index}\n상품명: 샘플 상품 ${index + 1} 외 1건'),
              trailing: const Icon(Icons.chevron_right),
              isThreeLine: true,
              onTap: () {
                // TODO: 주문 상세 화면으로 이동
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('주문 ORD2025060${index + 1} 상세 보기 (구현 예정)')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}