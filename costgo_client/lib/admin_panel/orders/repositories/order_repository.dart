import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/order_model.dart'; // YOUR_APP_NAME 수정

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(FirebaseFirestore.instance);
});

// 모든 주문 목록을 스트림으로 제공하는 Provider (관리자용)
final orderListStreamProvider = StreamProvider.autoDispose<List<OrderModel>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrdersStream();
});


class OrderRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'orders'; // Firestore 컬렉션 이름

  OrderRepository(this._firestore);

  // 모든 주문 목록을 스트림으로 가져오기 (최신순)
  Stream<List<OrderModel>> getOrdersStream() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    });
  }

  // 주문 상태 업데이트
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection(_collectionPath).doc(orderId).update({
        'orderStatus': newStatus,
      });
    } catch (e) {
      throw Exception('주문 상태 업데이트 실패: $e');
    }
  }

  // TODO: 사용자 앱의 OrderFormScreen에서 호출될 주문 생성 메소드
  // Future<void> createOrder(OrderModel order) async { ... }
}