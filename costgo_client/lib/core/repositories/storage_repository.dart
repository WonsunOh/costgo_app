import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository(FirebaseStorage.instance);
});

class StorageRepository {
  final FirebaseStorage _storage;
  
  StorageRepository(this._storage);

  /// 이미지를 Firebase Storage에 업로드하고 다운로드 URL을 반환합니다.
  /// [folderPath] 예시: "products/images", "users/avatars"
  Future<String> uploadImage({
    required XFile imageFile,
    required String folderPath,
  }) async {
    try {
      // 파일 이름이 중복되지 않도록 고유 ID 생성
      final fileId = const Uuid().v4();
      // 원본 파일의 확장자 가져오기
      final fileExtension = imageFile.name.split('.').last;
      final fileName = '$fileId.$fileExtension';

      // Storage에 저장될 경로 참조 생성
      final Reference ref = _storage.ref().child(folderPath).child(fileName);

      // 파일 업로드
      UploadTask uploadTask;
      if (kIsWeb) {
        // 웹 환경에서는 파일 바이트를 업로드
        uploadTask = ref.putData(await imageFile.readAsBytes());
      } else {
        // 모바일 환경에서는 파일 경로로 업로드
        uploadTask = ref.putFile(File(imageFile.path));
      }

      // 업로드 완료까지 대기
      final TaskSnapshot snapshot = await uploadTask;

      // 업로드된 파일의 다운로드 URL 가져오기
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('이미지 업로드 실패: $e');
      throw Exception('이미지 업로드에 실패했습니다: $e');
    }
  }
}