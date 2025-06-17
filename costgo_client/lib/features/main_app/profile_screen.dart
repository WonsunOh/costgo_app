import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
// ... (다른 메뉴 화면 import)

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCurrentUser = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        centerTitle: true,
      ),
      body: asyncCurrentUser.when(
        data: (user) {
          if (user == null) {
            // 로그인 상태가 아니면 로그인 안내
            return Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
                child: const Text('로그인하기'),
              ),
            );
          }
          // 로그인된 경우 UI 표시
          return ListView(
            children: <Widget>[
              _buildUserProfileSection(context, user),
              const Divider(height: 8, thickness: 8),
              _buildMenuListTile(
                context,
                icon: Icons.person_outline,
                title: '개인 정보 수정',
                onTap: () { /* TODO: EditProfileScreen으로 이동 */ },
              ),
              // ... 다른 메뉴 ListTile ...
              const Divider(),
              _buildMenuListTile(
                context,
                icon: Icons.logout,
                title: '로그아웃',
                onTap: () async {
                  // Notifier의 signOut 메소드 호출
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('사용자 정보 로드 오류: $e')),
      ),
    );
  }

  Widget _buildUserProfileSection(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            child: Text(user.name.isNotEmpty ? user.name[0] : ''),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.name}님', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user.email, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuListTile(BuildContext context, {required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}