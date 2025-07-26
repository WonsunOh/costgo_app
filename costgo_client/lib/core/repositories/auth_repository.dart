import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../../providers/dio_provider.dart';

/// authRepositoryProvider가 dioProvider를 사용하도록 수정합니다.
final authRepositoryProvider = Provider((ref) => AuthRepository(
      dio: ref.watch(dioProvider), // ref.watch(dioProvider) 사용
    ));

class AuthRepository {
  final Dio dio;

  // baseUrl을 직접 받지 않고, dioProvider에 설정된 값을 사용합니다.
  AuthRepository({required this.dio});

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login', // 기본 URL이 dio에 설정되어 있으므로 뒷부분만 작성합니다.
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['user']);
        final token = response.data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('x-auth-token', token);
        await prefs.setString('user', jsonEncode(user.toJson()));

        return user;
      } else {
        throw Exception('Failed to login: ${response.data['msg']}');
      }
    } on DioException catch (e) {
      // Dio 에러의 경우, 더 자세한 정보를 포함하여 예외를 던집니다.
      throw Exception('Failed to login: ${e.response?.data['msg'] ?? e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<UserModel> signUp(String username, String email, String password) async {
  // ================== DEBUG LOG ==================
  print('[DEBUG] AuthRepository: signUp 메소드 시작');
  // ===============================================

    try {
      final response = await dio.post(
        '/auth/signup',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['user']);
        final token = response.data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('x-auth-token', token);
        await prefs.setString('user', jsonEncode(user.toJson()));
        
        return user;
      } else {
        throw Exception('Failed to sign up: ${response.data['msg']}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to sign up: ${e.response?.data['msg'] ?? e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('x-auth-token');
    await prefs.remove('user');
  }

  Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token');

      if (token == null) {
        return null;
      }

      final response = await dio.get(
        '/auth/me',
        options: Options(
          headers: {'x-auth-token': token},
        ),
      );

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
         await prefs.setString('user', jsonEncode(user.toJson()));
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}