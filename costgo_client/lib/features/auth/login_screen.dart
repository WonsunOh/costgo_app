import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 로그인 에러가 발생했을 때만 SnackBar를 보여주도록 listen합니다.
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // 화면 이동 로직은 GoRouter가 처리하므로 여기서는 제거합니다.
      if (next is AuthError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.message)),
          );
      }
    });

    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: '이메일'),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (authState is AuthLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref.read(authNotifierProvider.notifier).login(
                              _emailController.text,
                              _passwordController.text,
                            );
                      }
                    },
                    child: const Text('로그인'),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // MaterialPageRoute 대신 GoRouter의 경로를 사용합니다.
                      context.push('/signup'); 
                  },
                  child: const Text('회원가입'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text('비밀번호 찾기'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}