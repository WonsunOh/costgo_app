import 'package:costgo_app/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;

  CartItemModel({
    required this.product,
    required this.quantity,
  });

  // 서버에서 받은 JSON 데이터를 CartItemModel 객체로 변환하는 팩토리 생성자
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      // 'product' 필드는 위에서 populate 했기 때문에 Product 객체 전체가 들어옵니다.
      product: ProductModel.fromJson(json['product']),
      quantity: (json['quantity'] as num).toInt(),
    );
  }

  // 이 객체를 다시 JSON으로 변환할 때 사용 (현재는 서버로 보낼 때 직접 만들어서 사용 중)
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}