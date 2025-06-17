
class UserModel {
  final String uid; // Firebase Auth UID와 동일
  final String name;
  final String email;
  final String? phoneNumber;
  final String? address;
  final DateTime? createdAt;
  final bool additionalInfoCompleted; // ★★★ 추가 정보 입력 완료 여부 플래그 ★★★
  final bool isAdmin; // ★★★ 관리자 여부 필드 추가 ★★★

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.address,
    this.createdAt,
    this.additionalInfoCompleted = false, // 기본값은 false
    this.isAdmin = false, // 기본값은 false
  });

  // fromJson (또는 fromMap) factory 생성자
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        uid: json['_id'] as String? ?? json['uid'] as String? ?? '',
        name: json['name'] as String? ?? '이름 없음',
        email: json['email'] as String? ?? '이메일 없음',
        // 어떤 타입으로 오든 문자열로 안전하게 변환
        phoneNumber: json['phoneNumber']?.toString(), 
        address: json['address']?.toString(), 
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) // .toString() 추가
            : null,
       // ★★★ _parseBool 함수 호출 ★★★
        additionalInfoCompleted: _parseBool(json['additionalInfoCompleted']),
        isAdmin: _parseBool(json['isAdmin']),
      );
    } catch (e, s) {
      print('--- UserModel.fromJson 파싱 에러 ---');
      print('원본 JSON 데이터: $json');
      print('에러: $e');
      print('스택 트레이스: $s');
      print('------------------------------------');
      // 에러 발생 시에도 앱이 중단되지 않도록, 기본값으로 객체를 생성하거나 예외를 다시 던짐
      throw FormatException('사용자 데이터 파싱에 실패했습니다: $e');
    }
  }

 

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'additionalInfoCompleted': additionalInfoCompleted,
      'isAdmin': isAdmin,
    };
  }

UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    DateTime? createdAt,
    bool? additionalInfoCompleted,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      additionalInfoCompleted: additionalInfoCompleted ?? this.additionalInfoCompleted,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
 // bool 파싱을 위한 안전한 헬퍼 함수
bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  if (value is num) {
    return value != 0;
  }
  return false;
}