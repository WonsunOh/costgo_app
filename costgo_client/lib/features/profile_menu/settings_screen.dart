import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앱 설정'),
      ),
      body: const Center(
        child: Text('앱 설정 화면 (알림, 버전 정보 등)', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}