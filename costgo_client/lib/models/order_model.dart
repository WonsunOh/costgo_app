import 'package:costgo_app/models/product_model.dart';
import 'package:costgo_app/models/user_model.dart';

// 주문 내역에 포함된 개별 상품을 위한 모델
class OrderItemModel {
  final ProductModel product;
  final int quantity;
  final double price; // 주문 당시의 상품 가격

  OrderItemModel({
    required this.product,
    required this.quantity,
    required this.price,
  });

  // 서버에서 받은 JSON을 OrderItemModel 객체로 변환
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      // product 필드가 populate 되어 Product 객체 전체가 내려옵니다.
      product: ProductModel.fromJson(json['product']),
      quantity: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
    );
  }

  // 서버로 주문 정보를 보낼 때 사용할 JSON 형식
  Map<String, dynamic> toJson() {
    return {
      'product': product.id, // 새 주문을 생성할 때는 상품의 ID만 보냅니다.
      'quantity': quantity,
      'price': price,
    };
  }
}

// 메인 주문 모델
class OrderModel {
  final String id;
  final List<OrderItemModel> products;
  final double totalPrice;
  final String shippingAddress;
  final UserModel orderedBy;
  final DateTime orderedAt;
  final String status;

  OrderModel({
    required this.id,
    required this.products,
    required this.totalPrice,
    required this.shippingAddress,
    required this.orderedBy,
    required this.orderedAt,
    required this.status,
  });

  // 서버에서 받은 JSON을 OrderModel 객체로 변환하는 팩토리 생성자
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      // products 리스트의 각 항목을 OrderItemModel로 변환합니다.
      products: (json['products'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      shippingAddress: json['shippingAddress'],
      // orderedBy 필드가 populate 되어 User 객체 전체가 내려옵니다.
      orderedBy: UserModel.fromJson(json['orderedBy']),
      orderedAt: DateTime.parse(json['orderedAt']),
      status: json['status'],
    );
  }
}