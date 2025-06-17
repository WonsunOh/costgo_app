import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'features/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter 엔진과 위젯 바인딩 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  // Kakao SDK 초기화
  KakaoSdk.init(nativeAppKey: '2a7a8f3cde4dacd4593de5d46974f366'); // 발급받은 네이티브 앱 키
  // Firebase 앱 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // firebase_options.dart 사용
  );
  runApp(
    const ProviderScope( // Riverpod 사용을 위한 ProviderScope
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Costgo Shop', // 앱 제목 (이전 오타 수정)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, // Material 3 디자인 사용 권장
      ),
      home: const SplashScreen(),
      // home: const AdminMainScreen(),
      localizationsDelegates: [
        // 앱에서 사용할 로컬라이제이션 델리게이트 추가
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ], // 앱의 첫 화면으로 AuthWrapper 사용
    );
  }
}


