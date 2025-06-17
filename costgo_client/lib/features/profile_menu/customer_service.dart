import 'package:flutter/material.dart';

class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객센터'),
      ),
      body: ListView( // 고객센터는 보통 여러 항목이 있으므로 ListView 사용
        children: const [
          ListTile(title: Text('공지사항')),
          ListTile(title: Text('자주 묻는 질문 (FAQ)')),
          ListTile(title: Text('1:1 문의하기')),
          // 각 항목별로 실제 화면 연결 또는 상세 내용 표시 필요
        ],
      ),
    );
  }
}