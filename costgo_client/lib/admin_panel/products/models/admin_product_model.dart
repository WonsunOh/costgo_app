import 'package:uuid/uuid.dart';

class AdminProduct {
  final String id;
  String imageUrl;
  String name;
  String category;
  double price;
  int stock;
  String status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? description;
  List<String> productTypes;

  AdminProduct({
    String? id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl = '',
    this.status = '판매중',
    this.createdAt,
    this.updatedAt,
    this.description,
    this.productTypes = const [],
  }) : id = id ?? const Uuid().v4();

  // ★★★ fromFirestore -> fromJson으로 변경 ★★★
  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    return AdminProduct(
      id: json['_id'] as String? ?? json['id'] as String? ?? '', // MongoDB는 _id 필드 사용
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      status: json['status'] as String? ?? '숨김',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      description: json['description'] as String?,
      productTypes: List<String>.from(json['productTypes'] as List<dynamic>? ?? []),
    );
  }

  // toMap 메소드는 Node.js API로 보낼 데이터 구조에 맞게 유지 또는 수정
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'status': status,
      'description': description,
      'productTypes': productTypes,
    };
  }

  // 객체 복사를 위한 copyWith 메소드 (수정 모드 등에서 유용)
  AdminProduct copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
    bool forceNullDescription = false, // description을 명시적으로 null로 만들고 싶을 때
    List<String>? productTypes, // productTypes를 수정할 때 사용
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: forceNullDescription ? null : (description ?? this.description),
      productTypes: productTypes ?? this.productTypes, // productTypes만 업데이트 가능하게
    );
  }

  // ProductDetailScreen에서 사용할 Product 모델로 변환 (필드명이 유사하다고 가정)
  // Product toUserAppProduct() {
  //   return Product(
  //     id: id,
  //     name: name,
  //     imageUrl: imageUrl,
  //     price: price,
  //     // Product 모델에 categoryId, discount 등이 있다면 여기서 매핑
  //     categoryId: category, // AdminProduct의 category가 Product의 categoryId와 매핑된다고 가정
  //     discount: status == '할인중' ? '10%' : null, // 임시 할인 로직 예시
  //     // Product 모델에 없는 AdminProduct만의 필드는 제외
  //   );
  // }
}