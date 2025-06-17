import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainScreenCurrentTabProvider = StateProvider<int>((ref) => 0); // 초기 탭은 0 (홈)