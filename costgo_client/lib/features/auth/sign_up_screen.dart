import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/auth_repository.dart';
import 'login_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
   final _phoneController = TextEditingController(); // 연락처 컨트롤러 추가
  final _addressController = TextEditingController(); // 주소 컨트롤러 추가

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // 약관 동의 상태
  bool _agreeToTerms = false;
  bool _agreeToPrivacyPolicy = false;
  // bool _agreeToMarketing = false; // 선택 약관 예시

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _signUpUser() async {
    FocusScope.of(context).unfocus();

    if (!_agreeToTerms || !_agreeToPrivacyPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 약관에 모두 동의해주세요.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Node.js 백엔드 API를 호출하는 AuthRepository의 signUp 메소드
        await ref.read(authRepositoryProvider).signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입이 완료되었습니다. 로그인 해주세요.')),
          );
          // 회원가입 성공 후 로그인 화면으로 이동 (이전 화면 스택 모두 제거)
          Navigator.of(context).pushAndRemoveUntil(
             MaterialPageRoute(builder: (context) => const LoginScreen()),
             (route) => false
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('회원가입 실패: ${e.toString().replaceFirst("Exception: ", "")}')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  '새로운 계정을 만들어보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 30),

                // 이름 입력 필드
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: '이름',
                    hintText: '홍길동',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 이메일 입력 필드
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '이메일 주소',
                    hintText: 'you@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요.';
                    }
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return '유효한 이메일 주소를 입력해주세요.';
                    }
                    // TODO: 이메일 중복 확인 로직 필요 (API 연동 시)
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 비밀번호 입력 필드
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    hintText: '6자 이상 입력',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요.';
                    }
                    if (value.length < 6) {
                      return '비밀번호는 6자 이상이어야 합니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 비밀번호 확인 입력 필드
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                    hintText: '비밀번호를 다시 입력해주세요',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력해주세요.';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                // 연락처 필드 추가
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '연락처 (선택)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                // 주소 필드 추가
                TextFormField(
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  decoration: const InputDecoration(
                    labelText: '주소 (선택)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                // 약관 동의
                _buildAgreementCheckbox(
                  title: '서비스 이용약관 동의 (필수)',
                  value: _agreeToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                  onViewDetails: () { /* TODO: 약관 상세 보기 */ _showTermsDialog('서비스 이용약관'); },
                ),
                _buildAgreementCheckbox(
                  title: '개인정보 수집 및 이용 동의 (필수)',
                  value: _agreeToPrivacyPolicy,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreeToPrivacyPolicy = value ?? false;
                    });
                  },
                  onViewDetails: () { /* TODO: 약관 상세 보기 */ _showTermsDialog('개인정보 수집 및 이용 동의'); },
                ),
                // _buildAgreementCheckbox(  // 선택 약관 예시
                //   title: '마케팅 정보 수신 동의 (선택)',
                //   value: _agreeToMarketing,
                //   onChanged: (bool? value) {
                //     setState(() {
                //       _agreeToMarketing = value ?? false;
                //     });
                //   },
                //   onViewDetails: () { /* TODO: 약관 상세 보기 */ },
                // ),
                const SizedBox(height: 30),

                // 회원가입 버튼
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signUpUser,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('가입하기'),
                      ),
                const SizedBox(height: 20),

                // 로그인 화면으로 이동 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('이미 계정이 있으신가요?'),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // 이전 화면 (로그인 화면)으로 돌아가기
                      },
                      child: const Text('로그인하기'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 약관 동의 체크박스 위젯 (재사용 가능)
  Widget _buildAgreementCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    VoidCallback? onViewDetails,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          visualDensity: VisualDensity.compact,
        ),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
        if (onViewDetails != null)
          TextButton(
            onPressed: onViewDetails,
            child: const Text('보기', style: TextStyle(fontSize: 13, color: Colors.blue, decoration: TextDecoration.underline)),
          ),
      ],
    );
  }

  // 약관 상세 보기 다이얼로그 (임시)
  void _showTermsDialog(String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: const SingleChildScrollView(
            // TODO: 실제 약관 내용 로드 (예: assets/terms/service_terms.txt)
            child: Text('여기에 해당 약관의 전체 내용이 표시됩니다. 지금은 개발 중이므로 임시 텍스트입니다. 실제 서비스에서는 반드시 정확한 약관 내용을 포함해야 합니다.'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}