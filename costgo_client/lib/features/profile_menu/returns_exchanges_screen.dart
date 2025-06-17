import 'package:flutter/material.dart';

class ReturnsExchangesScreen extends StatelessWidget {
  const ReturnsExchangesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('취소/반품/교환 내역'),
        centerTitle: true,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '취소, 반품, 교환 신청 내역 및 처리 상태를 보여주는 화면입니다.\n(현재 준비 중)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}