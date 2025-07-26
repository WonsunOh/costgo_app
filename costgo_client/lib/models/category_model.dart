class CategoryModel {
  final String id;
  final String name;
  final String? parentId;
  // 'children'은 서버에서 오는 데이터가 아니므로, final을 제거하고
  // 클라이언트에서 데이터를 가공하여 채워넣을 수 있도록 List<CategoryModel> 타입으로 변경합니다.
  List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.name,
    this.parentId,
    // 기본값은 빈 리스트로 설정합니다.
    this.children = const [],
  });

  // fromJson 팩토리 생성자를 서버 응답에 맞게 수정합니다.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      // 서버에서는 '_id'로 오므로 정확히 매핑합니다.
      id: json['_id'],
      name: json['name'],
      // 서버에서 parent 필드가 null일 수 있습니다.
      parentId: json['parent'],
      // 'children' 필드는 더 이상 json에서 파싱하지 않습니다.
    );
  }

  // C/U/D 작업을 위해 toJson 메소드도 명확하게 정의합니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent': parentId,
    };
  }
}