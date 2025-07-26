import 'package:costgo_app/models/category_model.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final List<String> images;
  final CategoryModel? category;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.images,
    this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'images': images,
      'category': category?.id,
    };
  }
}