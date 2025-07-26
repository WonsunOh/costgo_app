import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/shared_preferences_provider.dart';

// Dio 인스턴스를 제공하는 Provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // 1. 주소를 '10.0.2.2'로 변경합니다. (iOS 시뮬레이터나 실제 기기에서는 다를 수 있습니다)
      baseUrl: 'http://10.0.2.2:3000/api',
      // 연결 시간 초과 설정 (5초)
      connectTimeout: const Duration(seconds: 5),
      // 응답 시간 초과 설정 (5초)
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
  
  // Dio Interceptor 추가
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // SharedPreferences에서 토큰을 가져옵니다.
        final prefs = await ref.read(sharedPreferencesProvider.future);
        final token = prefs.getString('x-auth-token');
        
        // 토큰이 있으면 헤더에 추가합니다.
        if (token != null) {
          options.headers['x-auth-token'] = token;
        }
        return handler.next(options); // 요청을 계속 진행합니다.
      },
      onError: (DioException e, handler) {
        // TODO: 401 Unauthorized 에러 발생 시 로그아웃 처리 등
        return handler.next(e);
      },
    ),
  );
  return dio;
});