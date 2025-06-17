import 'package:flutter/material.dart';

class AddressManagementScreen extends StatelessWidget {
  const AddressManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('배송지 관리'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt_outlined),
            tooltip: '새 배송지 추가',
            onPressed: () {
              // TODO: 새 배송지 추가 다이얼로그 또는 화면으로 이동
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('새 배송지 추가 기능 (구현 예정)')),
              );
            },
          )
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '등록된 배송지 목록을 보여주고, 추가/수정/삭제 기능을 제공합니다.\n(현재 준비 중)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}