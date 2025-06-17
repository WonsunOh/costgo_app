import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';
import 'additional_info_screen.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 이메일/비밀번호 로그인 시도
  Future<void> _handleEmailSignIn() async {
    // 폼 유효성 검사
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    // AuthNotifier의 signIn 메소드 호출
    await _performLoginLogic(
      loginAttemptFunction: () => ref.read(authProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          ),
    );
  }

  // Google 로그인 시도
  Future<void> _handleGoogleSignIn() async {
    // AuthNotifier의 signInWithGoogle 메소드 호출
    await _performLoginLogic(
      loginAttemptFunction: () => ref.read(authProvider.notifier).signInWithGoogle(),
      isSocialLogin: true,
    );
  }

  // 소셜 로그인 공통 처리 (현재는 스낵바만 표시)
  void _handleSocialSignIn(String providerName) {
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Node.js 백엔드용 $providerName 로그인 구현이 필요합니다.')),
    );
  }

  // 로그인 로직을 처리하는 통합 함수
  Future<void> _performLoginLogic({
    required Future<UserModel?> Function() loginAttemptFunction,
    bool isSocialLogin = false,
  }) async {
    FocusScope.of(context).unfocus();
    
    // 이메일 로그인일 경우에만 폼 유효성 검사
    if (!isSocialLogin) {
      if (!(_formKey.currentState?.validate() ?? false)) return;
    } else {
      _formKey.currentState?.reset(); // 소셜 로그인 시도 시에는 폼 에러 초기화
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final UserModel? loggedInUser = await loginAttemptFunction();

      if (loggedInUser != null && mounted) {
        // 로그인 성공 후, 다음 화면으로 직접 이동
        _navigateToNextScreen(loggedInUser);
      } else if (isSocialLogin && mounted) {
        // Google 로그인 시도 중 사용자가 창을 닫아 null이 반환된 경우
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google 로그인이 취소되었습니다.')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: ${e.toString().replaceAll("Exception: ", "")}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // 로그인 성공 후 화면 전환을 담당하는 헬퍼 함수
  void _navigateToNextScreen(UserModel user) {
    if (!mounted) return;
    
    final destinationScreen = user.additionalInfoCompleted
      ? const MainScreen()
      : AdditionalInfoScreen(user: user,);
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destinationScreen),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
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
                const SizedBox(height: 40),
                Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  '환영합니다!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '계정에 로그인하세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 40),

                // 이메일 입력 필드
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '이메일 주소',
                    hintText: 'you@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '이메일을 입력해주세요.';
                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                      return '유효한 이메일 주소를 입력해주세요.';
                    }
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
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '비밀번호를 입력해주세요.';
                    if (value.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // 비밀번호 찾기 링크
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                    child: const Text('비밀번호를 잊으셨나요?'),
                  ),
                ),
                const SizedBox(height: 24),

                // 로그인 버튼
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailSignIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Text('로그인'),
                ),
                const SizedBox(height: 24),

                // 회원가입 링크
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('계정이 없으신가요?'),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUpScreen())),
                      child: const Text('회원가입'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // 소셜 로그인 구분선
                Row(
                  children: <Widget>[
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text('또는 다음 계정으로 로그인', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // 소셜 로그인 버튼 영역
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialLoginButton(
                      iconPath: 'assets/icons/google_logo.png',
                      onTap: _isLoading ? null : _handleGoogleSignIn,
                      label: 'Google',
                      isIconData: false,
                    ),
                    _buildSocialLoginButton(
                      iconData: Icons.chat_bubble,
                      onTap: _isLoading ? null : () => _handleSocialSignIn('KaKao'), // TODO: 네이버/카카오 로그인 로직 연결
                      label: 'Kakao',
                      color: const Color(0xFFFEE500),
                      iconColor: Colors.black87,
                    ),
                    _buildSocialLoginButton(
                      iconData: Icons.article_outlined,
                      onTap: _isLoading ? null : () => _handleSocialSignIn('Naver'), // TODO: 네이버/카카오 로그인 로직 연결
                      label: 'Naver',
                      color: const Color(0xFF03C75A),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 소셜 로그인 버튼 위젯 (재사용 가능하도록 분리)
  Widget _buildSocialLoginButton({
    String? iconPath,
    IconData? iconData,
    VoidCallback? onTap,
    required String label,
    Color color = Colors.white,
    Color iconColor = Colors.black,
    bool isIconData = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Semantics(
          label: label,
          child: isIconData
              ? Icon(iconData, color: iconColor, size: 28)
              : Image.asset(iconPath!, width: 28, height: 28),
        )
      ),
    );
  }
}