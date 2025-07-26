// costgo_client/lib/providers/product_provider.dart (새 파일)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:costgo_app/core/repositories/product_repository.dart';

import '../models/product_model.dart'; // 실제 ProductModel로 경로 수정 필요

// 상품 목록을 비동기적으로 제공하는 FutureProvider
final productsProvider = FutureProvider<List<ProductModel>>((ref) {
  // productRepositoryProvider를 통해 상품 데이터를 가져옵니다.
  return ref.watch(productRepositoryProvider).getProducts();
});

// ID를 인자로 받아 특정 상품의 상세 정보를 비동기적으로 제공하는 FutureProvider.family
final productDetailProvider =
    FutureProvider.family<ProductModel, String>((ref, productId) {
  // productRepositoryProvider를 통해 특정 상품 데이터를 가져옵니다.
  return ref.watch(productRepositoryProvider).getProductById(productId);
});