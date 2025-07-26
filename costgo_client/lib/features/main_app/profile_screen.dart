// costgo_client/lib/features/main_app/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // authNotifierProvider를 watch하여 인증 상태를 가져옵니다.
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
      ),
      // body: authState is Authenticated
      //     ? ListView(
      //         children: [
      //           UserAccountsDrawerHeader(
      //             accountName: Text(authState.user.username),
      //             accountEmail: Text(authState.user.email),
      //             currentAccountPicture: CircleAvatar(
      //               // 이미지가 있다면 표시, 없다면 기본 아이콘
      //               backgroundImage: authState.user.profileImageUrl != null
      //                   ? NetworkImage(authState.user.profileImageUrl!)
      //                   : null,
      //               child: authState.user.profileImageUrl == null
      //                   ? const Icon(Icons.person, size: 50)
      //                   : null,
      //             ),
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.edit),
      //             title: const Text('회원 정보 수정'),
      //             onTap: () {
      //               // GoRouter를 사용하여 프로필 수정 화면으로 이동
      //               context.push('/profile/edit');
      //             },
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.list_alt),
      //             title: const Text('주문 내역'),
      //             onTap: () {
      //               // TODO: 주문 내역 화면으로 이동
      //             },
      //           ),
      //           ListTile(
      //             leading: const Icon(Icons.favorite_border),
      //             title: const Text('찜한 상품'),
      //             onTap: () {
      //               // GoRouter를 사용하여 찜한 상품 화면으로 이동
      //               context.push('/profile/wishlist');
      //             },
      //           ),
      //           const Divider(),
      //           ListTile(
      //             leading: const Icon(Icons.logout, color: Colors.red),
      //             title: const Text('로그아웃'),
      //             onTap: () async {
      //               // 로그아웃 버튼을 누르면 authNotifier의 logout 메소드 호출
      //               await ref.read(authNotifierProvider.notifier).logout();
      //               // 화면 이동은 GoRouter가 자동으로 처리합니다.
      //             },
      //           ),
      //         ],
      //       )
      //     : const Center(
      //         // 인증 정보가 로딩 중이거나 없을 경우 (이론상 GoRouter가 막아줌)
      //         child: CircularProgressIndicator(),
      //       ),

     body: switch (authState) {
        Authenticated(:final user) => _buildLoggedInView(context, ref, user),
        _ => _buildLoggedOutView(context),
      },
    );
  }

  // 로그인 되었을 때 보여줄 위젯
  Widget _buildLoggedInView(BuildContext context, WidgetRef ref, UserModel user) {
    return ListView(
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(user.username),
          accountEmail: Text(user.email),
          // ... (기존과 동일)
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('회원 정보 수정'),
          onTap: () => context.push('/profile/edit'),
        ),
        ListTile(
          leading: const Icon(Icons.list_alt),
          title: const Text('주문 내역'),
          onTap: () => context.push('/profile/orders'),
        ),
        ListTile(
          leading: const Icon(Icons.favorite_border),
          title: const Text('찜한 상품'),
          onTap: () => context.push('/profile/wishlist'),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('로그아웃'),
          onTap: () async {
            await ref.read(authNotifierProvider.notifier).logout();
          },
        ),
      ],
    );
  }

  // 로그아웃 되었을 때 보여줄 위젯
  Widget _buildLoggedOutView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('로그인이 필요한 서비스입니다.'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('로그인 / 회원가입'),
          ),
        ],
      ),
    );
  }
}