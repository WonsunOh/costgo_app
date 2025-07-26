// costgo_client/lib/admin_panel/users/providers/user_providers.dart (새 파일)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/core/repositories/user_repository.dart';
import 'package:costgo_app/models/user_model.dart';

// 모든 사용자 목록을 비동기적으로 제공하는 FutureProvider
final allUsersProvider = FutureProvider<List<UserModel>>((ref) {
  // userRepositoryProvider를 통해 사용자 데이터를 가져옵니다.
  return ref.watch(userRepositoryProvider).getAllUsers();
});