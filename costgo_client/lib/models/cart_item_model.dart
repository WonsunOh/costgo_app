
import 'package:costgo_app/admin_panel/products/models/admin_product_model.dart';


class CartItem {
  final AdminProduct product;
  int quantity;
  bool isSelected;
  final String? selectedOptionsDescription; // 선택된 옵션 설명 (예: "색상: 레드, 사이즈: M")

  CartItem({
    required this.product,
    this.quantity = 1,
    this.isSelected = true,
    this.selectedOptionsDescription, // 생성자에 추가
  });

  double get totalPrice => product.price * quantity;

  // 상품 ID와 옵션 설명을 조합하여 고유한 키 생성 (장바구니 내 동일 상품 구분용)
  String get uniqueId => '${product.id}_${selectedOptionsDescription ?? ""}';

  CartItem copyWith({
    AdminProduct? product,
    int? quantity,
    bool? isSelected,
    String? selectedOptionsDescription, // copyWith에 추가
    bool clearSelectedOptions = false, // 옵션 설명을 명시적으로 null로 만들고 싶을 때 사용
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      selectedOptionsDescription: clearSelectedOptions ? null : selectedOptionsDescription ?? this.selectedOptionsDescription,
    );
  }
}