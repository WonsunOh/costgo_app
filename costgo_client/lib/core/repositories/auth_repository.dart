import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/user_model.dart';

// Dio 및 Secure Storage Provider
final dioProvider = Provider<Dio>((ref) => Dio(BaseOptions(baseUrl: 'http://localhost:3000/api')));
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());



class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;
   final GoogleSignIn _googleSignIn;
  final String _tokenKey = 'auth_token'; // 토큰 저장용 키

  AuthRepository(this._dio, this._storage, this._googleSignIn);

  // 이메일/비밀번호로 회원가입
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      // Node.js의 /api/auth/signup 엔드포인트에 POST 요청
      await _dio.post('/auth/signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'address': address,
      });
    } on DioException catch (e) {
      // 서버에서 보낸 에러 메시지(예: 이메일 중복)를 사용자에게 전달
      final errorMessage = e.response?.data['message'] ?? '회원가입 중 오류가 발생했습니다.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다.');
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final String token = response.data['token'];
      await _storage.write(key: _tokenKey, value: token);
      _dio.options.headers['Authorization'] = 'Bearer $token';

      // ★★★ 여기서 직접 JSON을 UserModel 객체로 변환하여 반환 ★★★
      return UserModel.fromJson(response.data['user']);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? '로그인 중 오류가 발생했습니다.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('알 수 없는 오류가 발생했습니다.');
    }
  }

  // tryAutoLogin도 UserModel?을 직접 반환하도록 수정
  Future<UserModel?> tryAutoLogin() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;

    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/auth/me'); 

      // ★★★ 서버 응답 데이터 직접 확인을 위한 로그 추가 ★★★
    print('--- 서버 응답 (tryAutoLogin) ---');
    print(response.data);
    print('----------------------------------');


     if (response.data != null && response.data['user'] is Map<String, dynamic>) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw Exception("서버 응답 형식이 올바르지 않습니다.");
      }
    } catch(e) {
      await signOut();
      return null;
    }
  }
  

  // 로그아웃
  Future<void> signOut() async {
    // 저장된 토큰 삭제
    await _storage.delete(key: _tokenKey);
    // dio 헤더에서 토큰 제거
    _dio.options.headers.remove('Authorization');
    // TODO: 백엔드에 /api/auth/logout 엔드포인트가 있다면 호출하여 서버 측 세션도 정리
  }
  

  // ★★★ signInWithGoogle 메소드 추가 ★★★
  Future<UserModel?> signInWithGoogle() async {
    try {
      // 1. Google 로그인 팝업/화면을 띄워 사용자 계정 정보 가져오기
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우
        return null;
      }

      // 2. Google 인증 토큰 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken; // 백엔드에 보낼 idToken

      if (idToken == null) {
        throw Exception('Google로부터 ID 토큰을 가져오지 못했습니다.');
      }
      
      // 3. 직접 만든 Node.js 백엔드의 소셜 로그인 엔드포인트에 토큰 전송
      //    예시: POST /api/auth/google
      final response = await _dio.post('/auth/google', data: {
        'idToken': idToken,
      });

      // 4. 백엔드로부터 받은 JWT와 사용자 정보 처리
      final String token = response.data['token'];
      await _storage.write(key: _tokenKey, value: token);
      
      _dio.options.headers['Authorization'] = 'Bearer $token';

      return UserModel.fromJson(response.data['user']);

    } catch (e) {
      // Google 로그인 취소 외의 모든 에러 처리
      print('Google 로그인 과정에서 오류 발생: $e');
      // 이미 로그아웃된 상태일 수 있으므로 여기서도 로그아웃 처리
      await _googleSignIn.signOut();
      throw Exception('Google 로그인에 실패했습니다.');
    }
  }
  
}

// ★★★ authRepositoryProvider 수정 ★★★
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // 생성자에 GoogleSignIn() 인스턴스 추가
  return AuthRepository(
    ref.read(dioProvider), 
    ref.read(secureStorageProvider),
    GoogleSignIn(), // GoogleSignIn 인스턴스 주입
  );
});