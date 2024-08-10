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
      final thumbUrl = await _locketService.uploadThumbnailFromVideo(userProfile.id, userProfile.idToken, video.path);
      if (thumbUrl != null) {
        final videoAsBytes = video.readAsBytesSync();
        final videoUrl =
            await _locketService.uploadVideoToFireStorage(userProfile.id, userProfile.idToken, videoAsBytes);
        if (videoUrl == null) {
          throw Exception('Failed to upload video to Firebase Storage');
        }
        final isPosted = await _locketService.postVideo(userProfile.idToken, videoUrl, thumbUrl, caption);
        if (isPosted) {
          return true;
        } else {
          print("Failed to upload video");
          throw Exception('Failed to post video');
        }
      } else {
        throw Exception('Failed to post video, size must be less than 10MB');
      }
    } catch (error) {
      rethrow;
    }
  }
}
