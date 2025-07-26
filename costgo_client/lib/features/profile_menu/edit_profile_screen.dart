import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:costgo_app/providers/auth_provider.dart';
import 'package:costgo_app/core/repositories/user_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  // TODO: 주소, 전화번호 등 추가 정보 컨트롤러 필요 시 여기에 추가

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // initState에서는 ref.watch를 사용할 수 없으므로, ref.read를 사용합니다.
    final user = (ref.read(authNotifierProvider) as Authenticated).user;
    
    _usernameController = TextEditingController(text: user.username);
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      final authState = ref.read(authNotifierProvider);
      if (authState is! Authenticated) {
        // 혹시 모를 예외 상황 처리
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증 정보가 유효하지 않습니다.')),
        );
        setState(() => _isLoading = false);
        return;
      }
      
      try {
        final userId = authState.user.id;
        final updateData = {
          'username': _usernameController.text,
          // 'email': _emailController.text, // 이메일은 보통 수정하지 않음
        };

        // 1. UserRepository를 통해 서버에 정보 업데이트 요청
        await ref.read(userRepositoryProvider).updateUser(userId, updateData);

        // 2. 앱의 전체적인 인증 상태(사용자 정보)를 새로고침
        await ref.read(authNotifierProvider.notifier).checkAuthState();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프로필이 성공적으로 업데이트되었습니다.')),
          );
          // 3. 이전 화면으로 돌아가기
          context.pop();
        }

      } catch (e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('프로필 업데이트 실패: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 정보 수정'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _submit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '사용자 이름',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? '사용자 이름을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일 (수정 불가)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.black12,
                ),
                readOnly: true, // 이메일은 수정하지 못하도록 설정
              ),
              // TODO: 주소, 전화번호 등 다른 필드 추가
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _submit,
                child: const Text('저장하기'),
              )
            ],
          ),
        ),
      ),
    );
  }
}