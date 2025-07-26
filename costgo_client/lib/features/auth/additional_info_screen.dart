import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/auth_provider.dart';
import 'package:costgo_app/core/repositories/user_repository.dart';

class AdditionalInfoScreen extends ConsumerStatefulWidget {
  const AdditionalInfoScreen({super.key});

  @override
  ConsumerState<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends ConsumerState<AdditionalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = (ref.read(authNotifierProvider) as Authenticated).user;
    _usernameController = TextEditingController(text: user.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);

      final authState = ref.read(authNotifierProvider);
      if (authState is! Authenticated) {
        setState(() => _isLoading = false);
        return;
      }
      
      try {
        final userId = authState.user.id;
        // 1. 서버 DB의 필드명인 'name'으로 데이터를 보내도록 수정합니다.
        //    'isProfileComplete'도 함께 보내 프로필 완성 상태를 업데이트합니다.
        final updateData = {
          'name': _usernameController.text,
          'isProfileComplete': true,
        };

        await ref.read(userRepositoryProvider).updateUser(userId, updateData);

        // 2. 앱의 전체적인 인증 상태(사용자 정보)를 새로고침합니다.
        //    이것이 완료되면 GoRouter가 자동으로 상태 변화를 감지합니다.
        await ref.read(authNotifierProvider.notifier).checkAuthState();

        // 3. 수동으로 화면을 이동시키는 context.go('/') 코드를 제거합니다.
        //    이제 모든 화면 전환은 router.dart가 책임집니다.

      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('정보 업데이트 실패: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (build 메소드의 UI 부분은 이전과 동일합니다)
    return Scaffold(
      appBar: AppBar(title: const Text('추가 정보 입력')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: '사용자 이름'),
                validator: (value) => value!.isEmpty ? '사용자 이름을 입력해주세요.' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3))
                    : const Text('저장하고 시작하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}