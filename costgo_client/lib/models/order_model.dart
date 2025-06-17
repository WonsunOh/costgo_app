import 'package:cloud_firestore/cloud_firestore.dart';

// 주문 내 개별 상품 모델
class OrderItemModel {
  final String productId;
  final String productName;
  final int quantity;
  final double price; // 주문 당시의 상품 가격

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'price': price,
  };

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '상품명 없음',
      quantity: map['quantity'] as int? ?? 0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// 전체 주문 모델
class OrderModel {
  final String orderId; // Firestore 문서 ID
  final String userId;
  final String customerName; // 주문자 이름
  final Map<String, dynamic> shippingAddress; // 배송 주소 정보
  final List<OrderItemModel> items; // 주문 상품 목록
  final double totalAmount; // 총 결제 금액
  final String orderStatus; // 주문 상태 (예: '결제완료', '배송중' 등)
  final Timestamp createdAt; // 주문 생성 시간

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.customerName,
    required this.shippingAddress,
    required this.items,
    required this.totalAmount,
    required this.orderStatus,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) throw StateError('OrderModel.fromFirestore: 문서 데이터가 없습니다.');
    return OrderModel(
      orderId: snapshot.id,
      userId: data['userId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '주문자 정보 없음',
      shippingAddress: data['shippingAddress'] is Map ? Map<String, dynamic>.from(data['shippingAddress']) : {},
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderStatus: data['orderStatus'] as String? ?? '상태 불명',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  // toMap 메소드는 주문 생성 시 Repository에서 직접 구성
}