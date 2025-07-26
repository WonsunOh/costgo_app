// costgo_client/lib/features/auth/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/auth_provider.dart';

class SignUpScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 회원가입 에러 발생 시 SnackBar를 보여줍니다.
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.message)));
      }
      // 성공 시 화면 이동은 GoRouter가 자동으로 처리합니다.
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: '사용자 이름'),
                validator: (value) => value!.isEmpty ? '사용자 이름을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: '이메일'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return '유효한 이메일 형식이 아닙니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) => (value?.length ?? 0) < 6 ? '비밀번호는 6자 이상이어야 합니다.' : null,
              ),
              const SizedBox(height: 24),
              if (authState is AuthLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () {
                    // ================== DEBUG LOG ==================
    print('[DEBUG] SignUpScreen: "가입하기" 버튼 눌림');
    // ===============================================
                    if (_formKey.currentState!.validate()) {
                      ref.read(authNotifierProvider.notifier).signUp(
                            _usernameController.text,
                            _emailController.text,
                            _passwordController.text,
                          );
                    }
                  },
                  child: const Text('가입하기'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}