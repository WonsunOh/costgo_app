import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 최소 스플래시 화면 표시 시간(예: 2초)을 보장하는 Provider
final splashDurationProvider = FutureProvider<void>((ref) async {
  await Future.delayed(const Duration(seconds: 3));
});