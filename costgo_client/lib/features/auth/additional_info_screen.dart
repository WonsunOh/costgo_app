import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/repositories/user_repository.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';

class AdditionalInfoScreen extends ConsumerStatefulWidget {
  final UserModel user;
  const AdditionalInfoScreen({super.key, required this.user});

  @override
  ConsumerState<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
}

class _AdditionalInfoScreenState extends ConsumerState<AdditionalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _phoneController.text = widget.user.phoneNumber ?? '';
    _addressController.text = widget.user.address ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitAdditionalInfo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final newName = _nameController.text.trim();
      final newPhone = _phoneController.text.trim();
      final newAddress = _addressController.text.trim();

      // 1. UserRepository를 통해 Firestore 문서 업데이트
      await ref.read(userRepositoryProvider).completeAdditionalInfo(
            uid: widget.user.uid,
            name: newName,
            phoneNumber: newPhone,
            address: newAddress,
          );
      
      // 2. ★★★ AuthProvider의 상태를 직접 업데이트 (API 재호출 X) ★★★
      //    기존 사용자 정보에 새로 입력된 값을 합쳐서 새로운 UserModel 객체를 만듭니다.
      final updatedUser = widget.user.copyWith( // UserModel에 copyWith 메소드가 필요합니다.
        name: newName,
        phoneNumber: newPhone,
        address: newAddress,
        additionalInfoCompleted: true,
      );

      // Notifier의 상태를 새로 만든 객체로 직접 업데이트합니다.
      ref.read(authProvider.notifier).setUser(updatedUser);
      
      if (mounted) {
        // 3. 성공 시 MainScreen으로 즉시 이동
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e, s) {
      print('--- 저장 실패 에러 정보 ---');
      print('에러 타입: ${e.runtimeType}');
      print('에러 메시지: $e');
      print('스택 트레이스: $s');
      print('--------------------------');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('정보 저장 실패: ${e.toString()}')));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이제 build 메소드는 Provider를 watch하지 않고, 컨트롤러에 바인딩된 폼만 그립니다.
    return Scaffold(
      appBar: AppBar(title: const Text('추가 정보 입력'), automaticallyImplyLeading: false),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('서비스 이용을 위해 추가 정보를 입력해주세요.', style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '이름', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? '이름을 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: '연락처 (선택)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: '주소', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? '주소를 입력해주세요.' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitAdditionalInfo,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text('저장하고 시작하기'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}