import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileStorageService {
  ProfileStorageService(this.storage);
  final FirebaseStorage storage;
  Future<String> uploadAvatar(String uid, Uint8List jpeg) async {
    if (jpeg.length > 2 * 1024 * 1024) {
      throw ArgumentError('Avatar exceeds 2 MB');
    }
    final reference = storage.ref('users/$uid/avatar.jpg');
    await reference.putData(jpeg, SettableMetadata(contentType: 'image/jpeg'));
    return reference.getDownloadURL();
  }
}
