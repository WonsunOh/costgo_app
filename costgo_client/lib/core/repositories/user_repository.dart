import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';
import 'auth_repository.dart'; // 이름 충돌 방지

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(dioProvider));
});

// 모든 사용자 목록을 제공하는 FutureProvider (관리자용)
final userListProvider = FutureProvider.autoDispose<List<UserModel>>((ref) {
  // TODO: 관리자 토큰을 사용하여 요청해야 함
  return ref.watch(userRepositoryProvider).getUsers();
});

class UserRepository {
  final Dio _dio;
  UserRepository(this._dio);

  

  // ★★★ 추가 정보 저장 및 완료 플래그 업데이트 메소드 ★★★
  Future<void> completeAdditionalInfo({
    required String uid, // 이 메소드는 이제 updateMyProfile로 대체 가능
    required String name,
    required String? phoneNumber,
    required String? address,
  }) async {
    try {
      // await updateMyProfile(name: name, phoneNumber: phoneNumber, address: address);
    // 추가로 additionalInfoCompleted 플래그만 따로 업데이트하는 API가 필요할 수 있음
    await _dio.put('/users/me', data: {
    'name': name,
    'phoneNumber': phoneNumber, // String으로 전달
    'address': address,
    'additionalInfoCompleted': true,
  });
    } on DioException catch (e) {
      throw Exception('추가 정보 저장 실패: ${e.response?.data['message'] ?? e.message}');
    }
  }

  // 모든 사용자 목록 가져오기
  Future<List<UserModel>> getUsers() async {
    try {
      // TODO: 요청 시 헤더에 관리자 인증 토큰 추가 필요
      // _dio.options.headers['Authorization'] = 'Bearer $adminToken';
      final response = await _dio.get('/users');
      final List<dynamic> userData = response.data;
      return userData.map((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('회원 목록을 불러오는 데 실패했습니다: $e');
    }
  }
  // 현재 로그인된 사용자의 프로필 정보 가져오기
  Future<UserModel> getCurrentUserProfile(String uid) async {
    try {
      final response = await _dio.get('/users/$uid');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('사용자 프로필을 불러오는 데 실패했습니다: $e');
    }
  }

  // 이름으로 사용자 검색 (관리자용)
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Node.js API에 검색 쿼리 전달 (예: /api/users?search=query)
      final response = await _dio.get('/users', queryParameters: {'search': query});
      final List<dynamic> userData = response.data;
      return userData.map((data) => UserModel.fromJson(data)).toList();
    } catch (e) {
      throw Exception('회원 검색 실패: $e');
    }
  }

  // 이 메소드는 로그인된 사용자가 자신의 정보를 수정할 때 사용됩니다.
  // Node.js 백엔드에서는 /api/users/me 와 같이 "나"를 지칭하는 엔드포인트를 사용하는 것이 일반적입니다.
  Future<UserModel> updateMyProfile({
    required String name,
    required String? phoneNumber,
    required String? address,
  }) async {
    try {
      // dio 인스턴스는 인터셉터를 통해 이미 인증 토큰을 가지고 있어야 합니다.
      final response = await _dio.put('/users/me', data: { // 예시: PUT /api/users/me
        'name': name,
        'phoneNumber': phoneNumber,
        'address': address,
      });
      // 성공 시 업데이트된 사용자 정보를 반환
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('프로필 업데이트 실패: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('프로필 업데이트 중 알 수 없는 오류가 발생했습니다.');
    }
  }

 
}
      // ... 다른 사용자 관련 API 호출 메소드 ...
      // --- 여기에 추가될 수 있는 메소드들 예시 ---

  // // 1. 특정 사용자 한 명의 정보 가져오기
  // //    (마이페이지에서 자신의 정보를 보거나, 관리자가 특정 회원 정보를 볼 때 사용)
  // Future<UserModel?> getSingleUser(String uid) async {
  //   final doc = await _firestore.collection(_collectionPath).doc(uid).get();
  //   if (doc.exists) {
  //     return UserModel.fromFirestore(doc);
  //   }
  //   return null;
  // }

  // // 2. 사용자 프로필 정보 업데이트
  // //    (사용자가 마이페이지에서 이름, 주소, 연락처 등을 직접 수정할 때 사용)
  // Future<void> updateUserProfile(String uid, Map<String, dynamic> dataToUpdate) async {
  //   // dataToUpdate 예시: {'name': '새이름', 'address': '새주소'}
  //   try {
  //     await _firestore.collection(_collectionPath).doc(uid).update({
  //       ...dataToUpdate,
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     throw Exception('프로필 업데이트 실패: $e');
  //   }
  // }

  // // 3. 사용자의 찜 목록(wishlist)에 상품 ID 추가/제거
  // //    (이 로직은 별도의 WishlistRepository로 분리하는 것이 더 좋을 수 있습니다)
  // Future<void> updateUserWishlist(String uid, String productId, {required bool shouldAdd}) async {
  //   try {
  //     final updateData = {
  //       'wishlistedProductIds': shouldAdd
  //           ? FieldValue.arrayUnion([productId])
  //           : FieldValue.arrayRemove([productId])
  //     };
  //     await _firestore.collection(_collectionPath).doc(uid).update(updateData);
  //   } catch (e) {
  //     throw Exception('찜 목록 업데이트 실패: $e');
  //   }
  // }

  // // 4. 관리자에 의한 사용자 상태 변경
  // //    (예: 사용자 계정 비활성화)
  // Future<void> updateUserStatus(String uid, String newStatus) async {
  //   // UserModel에 'status' 필드(예: 'active', 'suspended')가 추가되어야 함
  //   try {
  //     await _firestore.collection(_collectionPath).doc(uid).update({'status': newStatus});
  //   } catch (e) {
  //     throw Exception('사용자 상태 변경 실패: $e');
  //   }
  // }
 

 // 파일 하단에 추가
final searchedUserProvider = FutureProvider.autoDispose.family<List<UserModel>, String>((ref, query) {
  if (query.isEmpty) return [];
  return ref.watch(userRepositoryProvider).searchUsers(query);
});



  