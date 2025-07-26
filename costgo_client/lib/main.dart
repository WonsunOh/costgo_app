import 'package:costgo_app/core/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'admin_panel/router/admin_router.dart';


void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '2a7a8f3cde4dacd4593de5d46974f366'); // 발급받은 네이티브 앱 키

  // '--dart-define'으로 전달된 APP_TYPE 변수를 읽어옵니다.
  // 값이 없으면 기본값으로 'user'를 사용합니다.
  const appType = String.fromEnvironment('APP_TYPE', defaultValue: 'user');
  
  runApp(
    const ProviderScope( // Riverpod 사용을 위한 ProviderScope
      child:appType == 'admin' ? const AdminApp() : const UserApp(),
    ),
  );
}

class UserApp extends ConsumerWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // routerProvider를 구독합니다.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Costgo Shop', // 앱 제목 (이전 오타 수정)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Material 3 디자인 사용 권장
      ),
      localizationsDelegates: [
        // 앱에서 사용할 로컬라이제이션 델리게이트 추가
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ], 
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko'),
      // GoRouter의 라우팅 설정을 사용합니다.
      routerConfig: router, // 기본 로케일 설정// 앱의 첫 화면으로 AuthWrapper 사용
    );
  }
}

// 새로 만든 관리자 앱
class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 관리자 앱용 라우터를 사용합니다.
    final adminRouter = ref.watch(adminRouterProvider);

    return MaterialApp.router(
      title: 'CostGo Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      routerConfig: adminRouter,
    );
  }
}


