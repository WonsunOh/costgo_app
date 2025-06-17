import 'package:flutter/foundation.dart';

// SubCategory 모델
class SubCategory {
  final String id;
  final String name;

  SubCategory({
    required this.id,
    required this.name,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '이름 없음',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  SubCategory copyWith({
    String? id,
    String? name,
  }) {
    return SubCategory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'SubCategory(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubCategory && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}


// MainCategory 모델
class MainCategory {
  final String id; // Firestore 문서 ID
  final String name;
  final String iconPath;
  final List<SubCategory> subCategories;

  MainCategory({
    required this.id,
    required this.name,
    required this.iconPath,
    List<SubCategory>? subCategories,
  }) : subCategories = subCategories ?? const []; // const [] 사용

  factory MainCategory.fromJson(Map<String, dynamic> json) {
    return MainCategory(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '이름 없음',
      iconPath: json['iconPath'] as String? ?? 'assets/icons/default_category.png',
      subCategories: (json['subCategories'] as List<dynamic>? ?? [])
          .map((subData) => SubCategory.fromJson(subData as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconPath': iconPath,
      'subCategories': subCategories.map((sub) => sub.toMap()).toList(),
    };
  }

  MainCategory copyWith({
    String? id,
    String? name,
    String? iconPath,
    List<SubCategory>? subCategories,
  }) {
    return MainCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      subCategories: subCategories ?? this.subCategories,
    );
  }

  @override
  String toString() {
    return 'MainCategory(id: $id, name: $name, iconPath: $iconPath, subCategories: $subCategories)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is MainCategory &&
      other.id == id &&
      other.name == name &&
      other.iconPath == iconPath &&
      listEquals(other.subCategories, subCategories); // 리스트 비교
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      iconPath.hashCode ^
      subCategories.hashCode; // 리스트의 해시코드
  }
}