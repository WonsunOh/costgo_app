import 'package:costgo_app/models/cart_item_model.dart';
// ... 다른 import

class UserModel {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String? address;
  final String? phoneNumber;
  final String role;
  final List<String> wishList;
  // cart 필드를 List<CartItemModel> 타입으로 변경
  final List<CartItemModel> cart;
  // isProfileComplete 필드 추가
  final bool isProfileComplete;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.address,
    this.phoneNumber,
    this.role = 'user',
    this.wishList = const [],
    this.cart = const [], 
    this.isProfileComplete = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      username: json['username'] ?? 'No Username',
      email: json['email'] ?? 'No Email',
      profileImageUrl: json['profileImageUrl'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'user',
      wishList:
          json['wishList'] != null ? List<String>.from(json['wishList']) : [],
      
      // cart 필드를 파싱하는 로직 추가
      cart: json['cart'] != null && json['cart'] is List
          ? List<CartItemModel>.from(
              (json['cart'] as List)
                  .map((item) => CartItemModel.fromJson(item)),
            )
          : [],
          // isProfileComplete 필드 파싱 추가
      isProfileComplete: json['isProfileComplete'] ?? false,
    );
  }

  // toJson 메소드는 변경할 필요 없습니다.
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'phoneNumber': phoneNumber,
      'role': role,
      'wishList': wishList,
      // cart는 클라이언트에서 직접 조작하지 않고 API를 통해 변경하므로 toJson에 포함할 필요가 없습니다.
      'cart': cart.map((item) => item.toJson()).toList(),
    };
  }
}