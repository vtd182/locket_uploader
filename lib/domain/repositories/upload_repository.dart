import 'dart:io';

import 'package:locket_uploader/models/user_profile.dart';

import '../service/locket_service.dart';

abstract class UploadRepository {
  Future<bool?> postImageToLocket(UserProfile userProfile, File image, String caption);
  Future<bool?> postVideoToLocket(UserProfile userProfile, File video, String caption);
}

class UploadRepositoryImpl implements UploadRepository {
  final LocketService _locketService;

  UploadRepositoryImpl(this._locketService);

  @override
  Future<bool?> postImageToLocket(UserProfile userProfile, File image, String caption) async {
    try {
      final url = await _locketService.uploadImageToFirebaseStorage(
          userProfile.id, userProfile.idToken, image.readAsBytesSync());
      if (url != null) {
        final isPosted = await _locketService.postImage(userProfile.idToken, url, caption);
        return isPosted;
      } else {
        throw Exception('Failed to upload image, size must be less than 1MB');
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<bool?> postVideoToLocket(UserProfile userProfile, File video, String caption) async {
    try {
      final url = await _locketService.uploadThumbnailFromVideo(userProfile.id, userProfile.idToken, video.path);
      if (url != null) {
        final isPosted = await _locketService.postVideo(userProfile.idToken, video.path, url, caption);
        if (isPosted) {
          return true;
        } else {
          print("Failed to upload video");
          throw Exception('Failed to upload video');
        }
      } else {
        throw Exception('Failed to upload video, size must be less than 10MB');
      }
    } catch (error) {
      rethrow;
    }
  }
}
