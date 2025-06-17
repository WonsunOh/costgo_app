class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String? discount;
  final String categoryId; // 카테고리 ID 필드 추가

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.discount,
    required this.categoryId, // 생성자에 추가
  });
}