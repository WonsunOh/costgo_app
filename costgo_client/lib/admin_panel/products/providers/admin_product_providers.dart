// lib/admin_panel/products/providers/admin_product_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 새로 만든 공용 ProductModel을 임포트합니다.
import '../../../models/product_model.dart';
import '../repositories/admin_product_repository.dart';

final adminProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  return ref.watch(adminProductRepositoryProvider).getProducts();
});