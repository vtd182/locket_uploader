import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:locket_uploader/constants/constants.dart';
import 'package:locket_uploader/models/user_profile.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class LocketService {
  final Dio _dio = Dio();

  Future<UserProfile> login(String email, String password) async {
    try {
      final requestData = {
        "email": email,
        "password": password,
        "clientType": "CLIENT_TYPE_IOS",
        "returnSecureToken": true
      };
      Response response = await _dio.post(
        Constants.loginUrl,
        data: json.encode(requestData),
        options: Options(headers: Constants.loginHeader),
      );
      if (response.statusCode == 200) {
        final userProfile = UserProfile.fromJson(response.data);
        return userProfile;
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } catch (error) {
      print("Error in login: ${error.toString()}");
      rethrow;
    }
  }

  Future<String?> uploadImageToFirebaseStorage(String idUser, String idToken, Uint8List image) async {
    try {
      String nameImg = "${DateTime.now().millisecondsSinceEpoch}_vtd182.webp";
      int imageSize = image.lengthInBytes;

      String url =
          'https://firebasestorage.googleapis.com/v0/b/locket-img/o/users%2F$idUser%2Fmoments%2Fthumbnails%2F$nameImg?uploadType=resumable&name=users%2F$idUser%2Fmoments%2Fthumbnails%2F$nameImg';

      var headers = {
        'content-type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer $idToken',
        'x-goog-upload-protocol': 'resumable',
        'accept': '*/*',
        'x-goog-upload-command': 'start',
        'x-goog-upload-content-length': imageSize.toString(),
        'accept-language': 'vi-VN,vi;q=0.9',
        'x-firebase-storage-version': 'ios/10.13.0',
        'user-agent': 'com.locket.Locket/1.43.1 iPhone/17.3 hw/iPhone15_3 (GTMSUF/1)',
        'x-goog-upload-content-type': 'image/webp',
        'x-firebase-gmpid': '1:641029076083:ios:cc8eb46290d69b234fa609',
      };

      var data = json.encode({
        "name": "users/$idUser/moments/thumbnails/$nameImg",
        "contentType": "image/*",
        "bucket": "",
        "metadata": {"creator": idUser, "visibility": "private"}
      });

      Response response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: headers,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      String uploadUrl = response.headers.value('X-Goog-Upload-URL')!;
      await _dio.put(
        uploadUrl,
        data: image,
        options: Options(
          headers: Constants.uploaderHeader,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      var getUrl =
          'https://firebasestorage.googleapis.com/v0/b/locket-img/o/users%2F$idUser%2Fmoments%2Fthumbnails%2F$nameImg';
      var getHeaders = {'content-type': 'application/json; charset=UTF-8', 'authorization': 'Bearer $idToken'};
      response = await _dio.get(getUrl, options: Options(headers: getHeaders));
      String downloadToken = response.data['downloadTokens'];

      return "$getUrl?alt=media&token=$downloadToken";
    } catch (error) {
      return null;
    }
  }

  Future<String?> uploadVideoToFireStorage(String idUser, String idToken, Uint8List video) async {
    try {
      String nameVideo = "${DateTime.now().millisecondsSinceEpoch}_vtd182.mp4";
      int videoSize = video.lengthInBytes;

      String url =
          'https://firebasestorage.googleapis.com/v0/b/locket-video/o/users%2F$idUser%2Fmoments%2Fvideos%2F$nameVideo?uploadType=resumable&name=users%2F$idUser%2Fmoments%2Fvideos%2F$nameVideo';

      var headers = {
        'content-type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer $idUser',
        'x-goog-upload-protocol': 'resumable',
        'accept': '*/*',
        'x-goog-upload-command': 'start',
        'x-goog-upload-content-length': videoSize.toString(),
        'accept-language': 'vi-VN,vi;q=0.9',
        'x-firebase-storage-version': 'ios/10.13.0',
        'user-agent': 'com.locket.Locket/1.43.1 iPhone/17.3 hw/iPhone15_3 (GTMSUF/1)',
        'x-goog-upload-content-type': 'video/mp4',
        'x-firebase-gmpid': '1:641029076083:ios:cc8eb46290d69b234fa609',
      };

      var data = json.encode({
        "name": "users/$idUser/moments/videos/$nameVideo",
        "contentType": "video/mp4",
        "bucket": "",
        "metadata": {"creator": idUser, "visibility": "private"}
      });

      Response response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: headers,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      String uploadUrl = response.headers.value('X-Goog-Upload-URL')!;
      await _dio.put(
        uploadUrl,
        data: video,
        options: Options(
          headers: Constants.uploaderHeader,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      var getUrl =
          'https://firebasestorage.googleapis.com/v0/b/locket-video/o/users%2F$idUser%2Fmoments%2Fvideos%2F$nameVideo';
      var getHeaders = {'content-type': 'application/json; charset=UTF-8', 'authorization': 'Bearer $idToken'};
      response = await _dio.get(getUrl, options: Options(headers: getHeaders));
      String downloadToken = response.data['downloadTokens'];

      return "$getUrl?alt=media&token=$downloadToken";
    } catch (error) {
      return null;
    }
  }

  Future<String?> uploadThumbnailFromVideo(String idUser, String idToken, String videoPath) async {
    try {
      var thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 75,
      );

      if (thumbnailBytes == null) {
        throw Exception("Unable to create thumbnail");
      }
      return await uploadImageToFirebaseStorage(idUser, idToken, thumbnailBytes);
    } catch (error) {
      return null;
    }
  }

  Future<bool> postImage(String idToken, String thumbnailUrl, String caption) async {
    try {
      var postHeaders = {'content-type': 'application/json', 'authorization': 'Bearer $idToken'};
      var postData = json.encode({
        "data": {"thumbnail_url": thumbnailUrl, "caption": caption, "sent_to_all": true}
      });

      var response = await _dio.post("https://api.locketcamera.com/postMomentV2",
          data: postData, options: Options(headers: postHeaders));
      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }

  Future<bool> postVideo(String idToken, String videoUrl, String thumbnailUrl, String caption) async {
    try {
      var postHeaders = {'content-type': 'application/json', 'authorization': 'Bearer $idToken'};
      var postData = json.encode({
        "data": {"videoUrl": videoUrl, "thumbUrl": thumbnailUrl, "caption": caption}
      });

      var response = await _dio.post("https://api.locketcamera.com/postMomentV2",
          data: postData, options: Options(headers: postHeaders));
      final statusCode = response.data['result']['status'];
      final res = response.statusCode == 200 && statusCode != 401;
      return res;
    } catch (error) {
      return false;
    }
  }
}
