// costgo_client/lib/admin_panel/users/admin_user_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/admin_panel/users/providers/user_providers.dart';

class AdminUserScreen extends ConsumerWidget {
  const AdminUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // allUsersProvider를 watch하여 사용자 목록을 가져옵니다.
    final usersAsyncValue = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // provider를 invalidate하여 목록을 새로고침합니다.
              ref.invalidate(allUsersProvider);
            },
          ),
        ],
      ),
      body: usersAsyncValue.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('등록된 사용자가 없습니다.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(user.role == 'admin' ? 'A' : 'U'),
                  ),
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // TODO: 사용자 역할 변경 또는 삭제 등의 메뉴 표시
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('사용자 목록을 불러오지 못했습니다.\n오류: $err', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}